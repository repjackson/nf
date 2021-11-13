if Meteor.isClient
    Router.route '/trips', (->
        @layout 'layout'
        @render 'trips'
        ), name:'trips'
    Router.route '/user/:username/trips', (->
        @layout 'user_layout'
        @render 'user_trips'
        ), name:'user_trips'
    Router.route '/trip/:doc_id', (->
        @layout 'layout'
        @render 'trip_view'
        ), name:'trip_view'
    
    Template.trips.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'trip', ->
            
            
    Template.user_trips.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_trips', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_trips', Router.current().params.username, ->
            
    Template.trip_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.trip_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'trip_products', Router.current().params.doc_id
    

    Template.trip_view.helpers
        trip_products:->
            Docs.find
                model:'product'
                trip_id:@_id

    Template.trip_view.events
        'click .add_trip_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    trip_id: Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"        
            
    Template.trips.events
        'click .add_trip': ->
            new_id = 
                Docs.insert 
                    model:'trip'
            
            Router.go "/trip/#{new_id}/edit"
            
    Template.user_trips.events
        'click .add_trip': ->
            new_id = 
                Docs.insert 
                    model:'trip'
            
            Router.go "/trip/#{new_id}/edit"
            
            
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
            
           
           
            
    Template.user_trips.helpers
        sent_trips: ()->
            Docs.find   
                model:'trip'
                _author_username:Router.current().params.username
        received_trips: ()->
            Docs.find   
                model:'trip'
                recipient_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_trips', (username)->
        Docs.find   
            model:'trip'
            recipient_username:username
            
    Meteor.publish 'trip_products', (trip_id)->
        Docs.find   
            model:'product'
            trip_id:trip_id
            
            
    Meteor.publish 'user_sent_trips', (username)->
        Docs.find   
            model:'trip'
            _author_username:username
            
            
            
            
if Meteor.isClient
    Router.route '/trip/:doc_id/edit', (->
        @layout 'layout'
        @render 'trip_edit'
        ), name:'trip_edit'



    Template.trip_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.trip_edit.events
        'click .send_trip': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    trip = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update trip._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'trip sent',
                        ''
                        'success'
                    Router.go "/trip/#{@_id}/"
                    )
            )


            
    Template.trip_edit.helpers
        all_shop: ->
            Docs.find
                model:'trip'