require 'add_this_event/service'
require 'forwardable'
require 'ostruct'

module AddThisEvent
  class Params
    extend Forwardable

    VALID_SERVICES = %w(outlook google appleical outlookcom yahoo)
    DATE_FORMAT = 'MM/DD/YYYY'

    # Valid parameters. Full docs: https://addthisevent.com/api/
    KEYS = %i(all_day_event
              client
              start
              starttime
              startext
              date_format
              service
              title
              organizer
              organizer_email
              description
              location
              timezone)

    attr_reader :params

    delegate %i(title organizer description location organizer_email) => :params
    # KEYS = %i{start starttime startext end endtime endext title
    #           description location organizer all_day_event date_format
    #           timezone reference service template alarm}

    # ?client=
    # &start=06%2F25%2F2015
    # &starttime=09%3A00%3A00
    # &startext=AM
    # &end=06%2F25%2F2015
    # &endtime=11%3A00%3A00
    # &endext=AM
    # &title=Headline+of+the+event
    # &description=Description+of+the+event
    # &location=Eiffel+Tower%2C+Champ+de+Mars%2C+5+Anatole+France+Avenue%2C+75007+Paris%2C+France
    # &organizer=Your+Organization
    # &organizer_email=your%40email%2Ecom
    # &all_day_event=false
    # &date_format=MM%2FDD%2FYYYY
    # &timezone=Europe%2FParis
    # &reference=iphone+app
    # &service=appleical
    # &template=lm2015e14o720j11
    # &alarm=60#
    #
    # mandatory
    # &start= 06/25/2015
    # &end=
    # &title=
    # &date_format=
    # &timezone=#

    def initialize(params)
      @params = OpenStruct.new(params)
    end

    def to_h
      KEYS.each_with_object({}) { |key, output| output[key] = send(key) }
    end

    private

    def client
      return params.client_id unless params.client_id.nil?
      fail(ArgumentError, 'client_id must not be nil. Visit https://addthisevent.com/account/ to get your client_id (License Code)')
    end

    # Event start date. Mandatory. Format: "MM/DD/YYYY"
    def start
      params.starts_at.strftime('%m/%d/%Y')
    end

    # Event start time. Mandatory. Format: "HH/MM/SS"
    def starttime
      params.starts_at.strftime('%I:%M:%S')
    end

    # AM or PM
    def startext
      params.starts_at.strftime('%p')
    end

    def date_format
      DATE_FORMAT
    end

    def service
      AddThisEvent::Service.new(params[:service]).value
    end

    def timezone
      params.starts_at.zone
    end

    def all_day_event
      params.all_day_event == true
    end
  end
end
