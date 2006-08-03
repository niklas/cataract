module ActionMessenger
  module Messengers
    class Xmpp4rMessenger < ActionMessenger::Messenger
      # Creates a new messenger from its config hash.
      #
      # Hash can contain:
      #    jid:      the Jabber ID of this messenger, with resource if you wish.
      #    password: the password for this messenger.
      def initialize(config_hash = {})
        super(config_hash)
        @listeners = []
      
        # Sanity check the JID to ensure it has a resource, and add one ourselves if it doesn't.
        @jid = config_hash['jid']
        @jid += '/ActionMessenger' unless @jid =~ /\//
        @password = config_hash['password']
      
        # TODO: Different strategies for staying online (come online only to send messages.)
        # TODO: Reconnection strategy.
        # TODO: Multiple mechanisms for sending messages, for Jabber backend swap-out,
        #       but also to unit test the sending code.
     
        self.connect
        
        @client.on_exception do |ex|
          sleep 5
          log "exception caught: #{e.exception}" 
          @client.reconnect
        end

        @client.add_message_callback do |jabber_message|
          message = ActionMessenger::Message.new
          message.to = jabber_message.to.to_s
          message.from = jabber_message.from.to_s
          message.body = jabber_message.body
          message.subject = jabber_message.subject
          message_received(message)
        end
      end
    
      # Sends a message.
      def send_message(message)
        @client or self.reconnect or return
        to = message.to
        to = Jabber::JID.new(to) unless to.is_a?(Jabber::JID)
        jabber_message = Jabber::Message.new(to, message.body)
        jabber_message.subject = message.subject
        @client.send(jabber_message)
      end
      
      # TODO: See if there is a way to have this called on exit, for a more friendly shutdown.
      def shutdown
        unless @client.nil?
          @client.close
          @client = nil
        end
      end

      def connect
        begin
          log "connecting..."
          @client = Jabber::Client.new(Jabber::JID.new(@jid))
          @client.connect
          @client.auth(@password)
          log "connected!"
          return true
        rescue Errno::ECONNREFUSED
          log "connection refused"
          @client = nil
        rescue
          log "error: #{$!}"
          @client = nil
        end
      end
      alias reconnect connect

      def log(msg)
        STDERR.puts "#{self.class} (#{@jid}): #{msg}"
      end
    end
  end
end
