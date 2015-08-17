module Fluent
  class FieldEditorOutput < Output
    # First, register the plugin. NAME is the name of this plugin
    # and identifies the plugin in the configuration file.
    Fluent::Plugin.register_output('field_editor', self)
    
    config_param  :out_tag,           :string
    config_param  :edit_field,           :string
    config_param  :name_for_origin_key,     :string,  :default => nil
    config_param  :name_for_origin_value,     :string,  :default => nil

    #also need add config for info_name and postion_in_tag (start from 0) within <tag_infos> </tag_infos> block

    # This method is called before starting.
    def configure(conf)
      super
      # Read configuration for tag_infos and create a hash
      @tag_infos = Hash.new
      conf.elements.select { |element| element.name == 'tag_infos' }.each { |element|
        element.each_pair { |info_name, position_in_tag|
          element.has_key?(info_name) # to suppress unread configuration warning
          @tag_infos[info_name] = position_in_tag.to_i
          $log.info "Added tag_infos: #{info_name}=>#{@tag_infos[info_name]}"
        }
      }


    end

    # def initialize
    #   require 'highwatermark'
    #   super
    # end # def initialize

    # # This method is called when starting.
    # def start
    #   super
    #   @highwatermark = Highwatermark::HighWaterMark.new(@highwatermark_parameters)

    # end

    # # This method is called when shutting down.
    # def shutdown
    #   super
    # end

    # This method is called when an event reaches Fluentd.
    # 'es' is a Fluent::EventStream object that includes multiple events.
    # You can use 'es.each {|time,record| ... }' to retrieve events.
    # 'chain' is an object that manages transactions. Call 'chain.next' at
    # appropriate points and rollback if it raises an exception.
    #
    # NOTE! This method is called by Fluentd's main thread so you should not write slow routine here. It causes Fluentd's performance degression.
    def emit(tag, es, chain)

      chain.next
      es.each {|time,record|
        begin
          if record["event"]["alert_enriched"]=="Hostname"
            record["event"]["name"] = record["event"]["source_hostname"]

          elsif record["event"]["alert_enriched"]=="Application"
            record["event"]["name"] = record["event"]["application_name"]

          else
            if(!record["event"]["source_type"].nil? && !record["event"]["source_type"].empty?)  
              record["event"]["name"] = record["event"]["source_type"]
            else          
              record["event"]["name"] = "Empty Name"
            end
          end

          Fluent::Engine.emit @out_tag, time.to_i, record
        rescue Exception => e
          $log.error "could not edit field, just emit as same alert"
          $log.error e.message 
          $log.error e.backtrace.inspect
          Fluent::Engine.emit @out_tag, time.to_i, record
        end
	
      }
    end

  end
end
