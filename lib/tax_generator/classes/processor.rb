require_relative '../helpers/application_helper'
module TaxGenerator
  # class used to process xml files and create html files
  #
  # @!attribute options
  #   @return [Hash] the options that can determine the input and output files and folders
  #
  # @!attribute worker_supervisor
  #   @return [Celluloid::SupervisionGroup] the supervision group that supervises workers
  # @!attribute workers
  #   @return [Celluloid::Actor] the actors that will work on the jobs
  # @!attribute taxonomy
  #   @return [TaxGenerator::TaxonomyTree] the taxonomy tree that holds the nodes from the taxonomy xml document
  # @!attribute jobs
  #   @return [Hash] each key from the job list is the job id, and the value is the job itself
  # @!attribute job_to_worker
  #   @return [Hash] each key from the list is the job id, and the value is the worker that will handle the job
  # @!attribute worker_to_job
  #   @return [Hash] each key from the list is the workers mailbox address, and the value is the job being handled by the worker
  class Processor
    include Concurrent::Async
    include TaxGenerator::ApplicationHelper

    QUEUES = Concurrent::Map.new do |hash, queue_name| #:nodoc:
      hash.compute_if_absent(queue_name) {
        Concurrent::ThreadPoolExecutor.new(
          min_threads: 10, # create 10 threads at startup
          max_threads: 50, # create at most 50 threads
          max_queue: 0, # unbounded queue of work waiting for an available thread
        )
      }
    end

    attr_reader :options, :taxonomy, :jobs, :job_to_worker, :worker_to_job

    #trap_exit :worker_died

    #  receives a list of options that are used to determine the input files and output and input folders
    #
    # @param  [Hash]  options the options that can determine the input and output files and folders
    # @option options [String] :input_dir The input directory
    # @option options [String]:output_dir The output directory
    # @option options [String] :taxonomy_file_name The taxonomy file name
    # @option options [String] :destinations_file_name The destinations file name
    #
    # @see #work
    #
    # @return [void]
    #
    # @api public
    def initialize(options = {})
      @options = options.is_a?(Hash) ? options.symbolize_keys : {}
      @jobs_mutex = Mutex.new
      @job_to_worker_mutex = Mutex.new
      @worker_to_job_mutex = Mutex.new
      @jobs = {}
      @job_to_worker = {}
      @worker_to_job = {}
    end

    def enqueue(job_data, queue: 'default') #:nodoc:
      QUEUES[queue].post(job_data) { |job|
        TaxGenerator::FileCreator.spawn(name: "worker_#{job['atlas_id']}", args: [job, self])
      }
      end

      # otherwise the default path
      #
      # @return [String]
      #
      # @api public
      #  returns the input folder from the options list
      def input_folder
        @options.fetch(:input_dir, "#{root}/data/input")
      end

      #  returns the taxonomy filename from the option list
      # otherwise the default filename
      #
      # @return [String]
      #
      # @api public
      def taxonomy_file_name
        @options.fetch(:taxonomy_filename, 'taxonomy.xml')
      end

      #  returns the destinations filename from the option list
      # otherwise the default filename
      #
      # @return [String]
      #
      # @api public
      def destinations_file_name
        @options.fetch(:destinations_filename, 'destinations.xml')
      end

      #  returns the output folder path from the option list
      # otherwise the default path
      #
      # @return [String]
      #
      # @api public
      def output_folder
        @options.fetch(:output_dir, "#{root}/data/output")
      end

      #  returns the full path to the taxonomy file
      #
      # @return [String]
      #
      # @api public
      def taxonomy_file_path
        File.join(input_folder, taxonomy_file_name)
      end

      #  returns the full path to the destinations file
      #
      # @return [String]
      #
      # @api public
      def destinations_file_path
        File.join(input_folder, destinations_file_name)
      end

      #  returns the full path to the static folder
      #
      # @return [String]
      #
      # @api public
      def static_output_dir
        File.join(output_folder, 'static')
      end

      # cleans the output folder and re-creates it and the static folder
      #
      # @return [void]
      #
      # @api public
      def prepare_output_dirs
        FileUtils.rm_rf Dir["#{output_folder}/**/*"]
        create_directories(output_folder, static_output_dir)
        FileUtils.cp_r(Dir["#{File.join(root, 'templates', 'static')}/*"], static_output_dir)
      end

      #  checks if all workers finished and returns true or false
      #
      # @return [Boolean]
      #
      # @api public
      def all_workers_finished?
        @jobs_mutex.synchronize do
          @jobs.all? { |_job_id, job| job['status'] == 'finished' }
        end
      end

      #  registers all the jobs so that the managers can have access to them at any time
      #
      # @param  [Array] jobs the jobs that will be registered
      #
      # @return [void]
      #
      # @api public
      def register_jobs(*jobs)
        jobs.each do |job|
          job = job.stringify_keys
          @jobs_mutex.synchronize do
            @jobs[job['atlas_id']] = job
          end
        end
      end

      #  registers all the jobs, and then delegates them to workers
      # @see #register_jobs
      # @see TaxGenerator::FileCreator#work
      #
      # @param  [Array] jobs the jobs that will be delegated to the workers
      #
      # @return [void]
      #
      # @api public
      def delegate_job(*jobs)
        # jobs need to be added into the manager before starting task to avoid adding new key while iterating
        register_jobs(*jobs)
        @jobs_mutex.synchronize do
          @jobs.each do |_job_id, job|
            enqueue(job)
          end
        end
      end

      #  parses the destinations xml document, gets each destination and adds a new job for that
      # destination in the job list and then returns it
      # @see #nokogiri_xml
      #
      # @return [Array<Hash>]
      #
      # @api public
      def fetch_file_jobs
        jobs = []
        @taxonomy.taxonomies.each do |taxonomy_node|
          jobs << { atlas_id: taxonomy_node.name, taxonomy: @taxonomy, destination: nil, output_folder: output_folder }
        end
        nokogiri_xml(destinations_file_path).xpath('//destination').each do |destination|
          atlas_id = destination.attributes['atlas_id']
          jobs << { atlas_id: atlas_id.value, taxonomy: @taxonomy, destination: destination, output_folder: output_folder }
        end
        jobs
      end

      #  fetches the jobs for file generation, then delegates the jobs to workers and waits untill workers finish
      # @see #fetch_file_jobs
      # @see #delegate_job
      # @see #wait_jobs_termination
      #
      # @return [void]
      #
      # @api public
      def generate_files
        jobs = fetch_file_jobs
        delegate_job(*jobs)
        wait_jobs_termination
      end

      #  retrieves the information about the node from the tree and generates for each destination a new File
      # @see #create_file
      #
      # @return [void]
      #
      # @api public
      def wait_jobs_termination
        sleep(0.1) until all_workers_finished?
      end

      # registeres a worker inside the job_to_worker storage using the 'atlas_id' key from the job hash
      # @param  [TaxGenerator::FileCreator]  worker the worker that needs to be registered
      # @param  [Hash]  job the job that will be used to register the worker
      #
      # @return [void]
      #
      # @api public
      def register_job_to_worker(job, worker)
        @job_to_worker_mutex.synchronize do
          @job_to_worker[job['atlas_id']] = worker
        end
      end

      # registeres a job to a worker, using the mailbox address of the worker (which is unique)
      # @param  [TaxGenerator::FileCreator]  worker the worker that will be used to registerr the job
      # @param  [Hash]  job the job that willbe registered to a worker
      #
      # @return [void]
      #
      # @api public
      def register_worker_to_job(job, worker)
        @worker_to_job_mutex.synchronize do
          @worker_to_job[worker.name] = job
        end
      end

      #  registers the worker so that the current actor has access to it at any given time and starts the worker
      # @see TaxGenerator::FileCreator#start_work
      # @see #register_job_to_worker
      # @see #register_worker_to_job
      #
      # @param  [Hash]  job the job that the worker will work
      # @param  [TaxGenerator::FileCreator]  worker the worker that will create the file
      #
      # @return [void]
      #
      # @api public
      def register_worker_for_job(job, worker)
        register_job_to_worker(job, worker)
        register_worker_to_job(job, worker)
        log_message("worker #{worker.job_id} registed into manager")
        worker.tell(:start_work)
      end

      # generates the taxonomy tree , prints it and generates the files
      # @see TaxGenerator::TaxonomyTree#new
      # @see Tree::TreeNode#print_tree
      # @see #generate_files
      #
      # @return [void]
      #
      # @api public
      def work
        prepare_output_dirs
        if File.directory?(input_folder) && File.file?(taxonomy_file_path) && File.file?(destinations_file_path)
          @taxonomy = TaxGenerator::TaxonomyTree.new(taxonomy_file_path)
          @taxonomy.print_tree
          generate_files
        else
          log_message('Please provide valid options', log_method: 'fatal')
        end
      end

      # fetches the job from a worker
      # @param  [TaxGenerator::FileCreator]  worker the worker that died
      #
      # @return [void]
      #
      # @api public
      def get_job_from_worker(worker)
        @worker_to_job_mutex.synchronize do
          @worker_to_job[worker.name]
        end
      end

      # deletes the worker from the worker_to_job storage
      # @param  [TaxGenerator::FileCreator]  worker the worker that died
      #
      # @return [void]
      #
      # @api public
      def delete_from_worker_to_job(worker)
        name = worker.name
        @worker_to_job_mutex.synchronize do
          @worker_to_job.delete(name)
        end
        name
      end

      # logs the message about working being dead if a worker crashes
      # @param  [TaxGenerator::FileCreator]  worker the worker that died
      # @param  [String]  reason the reason for which the worker died
      #
      # @return [void]
      #
      # @api public
      def worker_died(worker, reason)
        job = get_job_from_worker(worker)
        worker_name = delete_from_worker_to_job(worker)
        return if reason.blank? || job.blank?
        log_message("worker job #{job['atlas_id']} with name #{worker_name.inspect} died  for reason:  #{log_error(reason)}", log_method: 'fatal')
      end
    end
  end
