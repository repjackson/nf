if Meteor.isClient
    Template.registerHelper 'transfer_products', () -> 
        Docs.find
            model:'product'
            transfer_id:@_id
    Template.registerHelper 'product_transfer', () -> 
        found = 
            Docs.findOne
                model:'transfer'
                _id:@transfer_id
        # console.log found
        found
    
    Router.route '/transfers', (->
        @layout 'layout'
        @render 'transfers'
        ), name:'transfers'
    Router.route '/transfer/:doc_id', (->
        @layout 'layout'
        @render 'transfer_view'
        ), name:'transfer_view'
    
    Template.transfers.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'transfer', 20, ->
            
            
            
    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'transfer_products', Router.current().params.doc_id
    

    Template.transfer_view.helpers
        transfer_products:->
            Docs.find
                model:'product'
                transfer_id:@_id

    Template.transfer_view.events
        'click .add_transfer_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    transfer_id: Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"        
            
    Template.transfers.events
        'click .add_transfer': ->
            new_id = 
                Docs.insert 
                    model:'transfer'
            
            Router.go "/transfer/#{new_id}/edit"
            
        
if Meteor.isServer
    Meteor.publish 'transfer_products', (transfer_id)->
        Docs.find   
            model:'product'
            transfer_id:transfer_id
            
            
if Meteor.isClient
    Router.route '/transfer/:doc_id/edit', (->
        @layout 'layout'
        @render 'transfer_edit'
        ), name:'transfer_edit'



    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'username_search', Session.get('username_query'), ->


    Template.user_picker.helpers
        unpicked_users: ->
            current_transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                _id:$ne:current_transfer.target_user_id
        picked_user: ->
            current_transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.findOne 
                _id:current_transfer.target_user_id
                
    Template.user_picker.events
        'click .pick_user': ->
            Docs.update Router.current().params.doc_id,
                $set:target_user_id:@_id
        'keyup .search_user': ->
            val = $('.search_user').val()
            Session.set('username_query',val)
        
    Template.transfer_edit.events
        'click .delete_transfer':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/transfers"

            
    Template.transfer_edit.helpers
        all_shop: ->
            Docs.find
                model:'transfer'
                
if Meteor.isServer
    Meteor.publish 'username_search', (query)->
        console.log 'search', query
        Meteor.users.find 
            username:{$regex:query,$options:'i'}