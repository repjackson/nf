if Meteor.isClient
    Template.user_giftcards.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_giftcards', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_giftcards', Router.current().params.username, ->
            
        # if Meteor.isDevelopment
    

    Template.user_giftcards.events
        'click .save_address': ->
            Session.set('editing_id',null)
        'click .edit_address': ->
            Session.set('editing_id',@_id)
        'click .remove_address': ->
            if confirm 'confirm delete?'
                Docs.remove @_id
        'click .add_address': ->
            new_id = 
                Docs.insert
                    model:'address'
            Session.set('editing_id',new_id)
            
           
           
            
    Template.user_giftcards.helpers
        is_editing_address: ->
            Session.equals('editing_id',@_id)
            
            
        user_address_docs: ->
            Docs.find 
                model:'address'
                _author_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_giftcards', (username)->
        Docs.find   
            model:'giftcard'
            recipient_username:username
            
            
    Meteor.publish 'user_sent_giftcards', (username)->
        Docs.find   
            model:'giftcard'
            _author_username:username
            
            
            