if Meteor.isClient
    Template.user_addresses.onCreated ->
        @autorun => Meteor.subscribe 'username_model_docs', 'address', Router.current().params.username, ->
            
        # if Meteor.isDevelopment
    

    Template.user_addresses.events
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
            
           
           
            
    Template.user_addresses.helpers
        is_editing_address: ->
            Session.equals('editing_id',@_id)
            
            
        user_address_docs: ->
            Docs.find 
                model:'address'
                _author_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'username_model_docs', (model, username)->
        if username 
            Docs.find   
                model:model
                _author_username:username
        else 
            Docs.find   
                model:model
                _author_username:Meteor.user().username