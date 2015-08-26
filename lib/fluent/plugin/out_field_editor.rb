module Fluent
  class FieldEditorOutput < Output
    # First, register the plugin. NAME is the name of this plugin
    # and identifies the plugin in the configuration file.
    Fluent::Plugin.register_output('field_editor', self)
    
    config_param  :out_tag,           :string

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
            # if(!record["event"]["source_type"].nil? && !record["event"]["source_type"].empty?)  
            #   record["event"]["name"] = record["event"]["source_type"]
            if(!record["event"]["source_hostname"].nil? && !record["event"]["source_hostname"].empty?)  
              record["event"]["name"] = record["event"]["source_hostname"]
            elsif (!record["event"]["application_name"].nil? && !record["event"]["application_name"].empty?)  
              record["event"]["name"] = record["event"]["application_name"]             
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
