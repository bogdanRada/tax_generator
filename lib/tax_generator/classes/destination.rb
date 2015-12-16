require_relative '../helpers/application_helper'
module TaxGenerator
  # class used to find xpaths from the destination node from xml
  #
  # @!attribute destination
  #   @return [Nokogiri::Element] the element from the xml document that need to be parsed
  class Destination
    include TaxGenerator::ApplicationHelper

    delegate :xpath,
             to: :destination

    attr_reader :destination

    # receives destination node (xml element) that need to be parsed
    #
    # @param  [Nokogiri::Element] destination_node the element from the xml document that need to be parsed
    #
    # @return [void]
    #
    # @api public
    def initialize(destination_node)
      @destination = destination_node
    end

    # returns the information about the introduction
    #
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def introduction
      xpath('.//introductory/introduction/overview')
    end

    # returns the information about the history
    #
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def history
      xpath('./history/history/history')
    end

    # returns the information about the practical_information
    #
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def practical_information
      base = './/practical_information/health_and_safety'
      xpath("#{base}/dangers_and_annoyances") + xpath("#{base}/while_youre_there") + \
        xpath("#{base}/before_you_go") + xpath("#{base}/money_and_costs/money")
    end

    # returns the information about the transport
    #
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def transport
      xpath('.//transport/getting_around')
    end

    # returns the information about the weather
    #
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def weather
      xpath('.//weather')
    end

    # returns the information about the work_live_study
    #
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def work_live_study
      xpath('.//work_live_study')
    end

    # returns the a hash containing all the parsed information from the xml document
    # and makes sure that only elements with content not blank will be returned
    #
    # @see #elements_with_content
    # @return [Nokogiri::NodeSet]
    #
    # @api public
    def to_hash
      {
        introduction: introduction,
        history: history,
        practical_information: practical_information,
        transport:  transport,
        weather: weather,
        work_live_study: work_live_study
      }.each_with_object({}) do |(key, value), hsh|
        hsh[key] = elements_with_content(value)
        hsh
      end
    end
  end
end
