if Meteor.isClient
    Template.registerHelper 'source_products', () -> 
        Docs.find
            model:'product'
            source_id:@_id
    Template.registerHelper 'product_source', () -> 
        found = 
            Docs.findOne
                model:'source'
                _id:@source_id
        console.log found
        found
    
    Router.route '/sources', (->
        @layout 'layout'
        @render 'sources'
        ), name:'sources'
    Router.route '/user/:username/sources', (->
        @layout 'user_layout'
        @render 'user_sources'
        ), name:'user_sources'
    Router.route '/source/:doc_id', (->
        @layout 'layout'
        @render 'source_view'
        ), name:'source_view'
    
    Template.sources.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'source', ->
            
            
    Template.user_sources.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_sources', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_sources', Router.current().params.username, ->
            
    Template.source_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.source_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'source_products', Router.current().params.doc_id
    

    Template.source_view.helpers
        source_products:->
            Docs.find
                model:'product'
                source_id:@_id

    Template.source_view.events
        'click .add_source_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    source_id: Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"        
            
    Template.sources.events
        'click .add_source': ->
            new_id = 
                Docs.insert 
                    model:'source'
            
            Router.go "/source/#{new_id}/edit"
            
    Template.user_sources.events
        'click .add_source': ->
            new_id = 
                Docs.insert 
                    model:'source'
            
            Router.go "/source/#{new_id}/edit"
            
            
        # 'click .edit_address': ->
        #     Session.set('editing_id',@_id)
        # 'click .remove_address': ->
        #     if confirm 'confirm delete?'
        #         Docs.remove @_id
        # 'click .add_address': ->
        #     new_id = 
        #         Docs.insert
        #             model:'address'
        #     Session.set('editing_id',new_id)
            
           
           
            
    Template.user_sources.helpers
        sent_sources: ()->
            Docs.find   
                model:'source'
                _author_username:Router.current().params.username
        received_sources: ()->
            Docs.find   
                model:'source'
                recipient_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_sources', (username)->
        Docs.find   
            model:'source'
            recipient_username:username
            
    Meteor.publish 'source_products', (source_id)->
        Docs.find   
            model:'product'
            source_id:source_id
            
            
    Meteor.publish 'user_sent_sources', (username)->
        Docs.find   
            model:'source'
            _author_username:username
            
            
            
            
if Meteor.isClient
    Router.route '/source/:doc_id/edit', (->
        @layout 'layout'
        @render 'source_edit'
        ), name:'source_edit'



    Template.source_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.source_edit.events
        'click .send_source': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    source = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update source._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'source sent',
                        ''
                        'success'
                    Router.go "/source/#{@_id}/"
                    )
            )

        'click .delete_source':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/sources"

            
    Template.source_edit.helpers
        all_shop: ->
            Docs.find
                model:'source'