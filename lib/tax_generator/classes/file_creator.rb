require_relative '../helpers/application_helper'
module TaxGenerator
  # class used to create the files
  #
  # @!attribute processor
  #   @return [TaxGenerator::Processor] the manager that manages the current actor
  # @!attribute job
  #   @return [Hash] the job that this actor received
  # @!attribute job_id
  #   @return [String] the id of the node from the taxonomy tree
  # @!attribute destination
  #   @return [Nokogiri::Element] the destination node from the xml document
  # @!attribute taxonomy
  #   @return [TaxGenerator::TaxonomyTree] the taxonomy tree holding all the nodes from the taxonomy xml document
  # @!attribute output_folder
  #   @return [String] the output folder where the new files will be created
  class FileCreator
    include Celluloid
    include Celluloid::Logger
    include TaxGenerator::ApplicationHelper

    attr_reader :processor, :job, :job_id, :destination, :taxonomy, :output_folder

    #  returns the template file path used for generating the files
    #
    # @return [void]
    #
    # @api public
    def template_name
      File.join(root, 'templates', 'template.html.erb')
    end

    #  processes the job received and registers itself inside the manager
    # @see TaxGenerator::Processor#register_worker_for_job
    # @see #process_job
    #
    # @param  [Hash] job the job that is passed to the current actor
    # @param  [TaxGenerator::Processor] manager the manager that manages the actor
    #
    # @return [void]
    #
    # @api public
    def work(job, manager)
      job = job.stringify_keys
      @job = job
      @processor = manager
      process_job(job)
      @processor.register_worker_for_job(job, Actor.current)
    end

    #  processes the job information by retrieving keys from the hash
    #
    # @param  [Hash] job the job that is passed to the current actor
    #
    # @return [void]
    #
    # @api public
    def process_job(job)
      job = job.stringify_keys
      @destination = job['destination']
      @job_id = job['atlas_id']
      @taxonomy = job['taxonomy']
      @output_folder = job['output_folder']
    end

    #  finds all the nodes in the tree with the given name
    #
    # @return [Array<Tree::TreeNode>]
    #
    # @api public
    def atlas_node
      @taxonomy.find_by_name(@job_id).first
    end

    #  renders the template and creates new file with the template html
    #
    # @return [void]
    #
    # @api public
    def start_work
      log_message "Generating html for destination #{@job_id}"
      output = Tilt.new(template_name).render(Actor.current, fetch_atlas_details)
      File.open(File.join(@output_folder, "#{@job_id}.html"), 'w') { |file| file << output }
      mark_job_completed
    end

    #  marks the job as completed after file is generated
    #
    # @return [void]
    #
    # @api public
    def mark_job_completed
      @processor.jobs[@job_id]['status'] = 'finished'
    end

    # fetches the details needed to be passed to the erb template
    # @see TaxGenerator::Destination#new
    #
    # @return [void]
    #
    # @api public
    def fetch_atlas_details
      content = @destination.present? ? TaxGenerator::Destination.new(@destination).to_hash : {}
      content.merge(details: atlas_node)
    end
  end
end
