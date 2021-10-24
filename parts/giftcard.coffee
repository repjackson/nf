if Meteor.isClient
    Router.route '/giftcards', (->
        @layout 'layout'
        @render 'giftcards'
        ), name:'giftcards'
    Router.route '/user/:username/giftcards', (->
        @layout 'user_layout'
        @render 'user_giftcards'
        ), name:'user_giftcards'
    Router.route '/giftcard/:doc_id', (->
        @layout 'layout'
        @render 'giftcard_view'
        ), name:'giftcard_view'
    
    Template.user_giftcards.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_giftcards', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_giftcards', Router.current().params.username, ->
            
    Template.giftcard_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.giftcard_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    

    Template.user_giftcards.events
        'click .send_giftcard': ->
            new_id = 
                Docs.insert 
                    model:'giftcard'
            
            Router.go "/giftcard/#{new_id}/edit"
            
            
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
            
           
           
            
    Template.user_giftcards.helpers
        is_editing_address: ->
            Session.equals('editing_id',@_id)
            
            
if Meteor.isServer
    Meteor.publish 'user_sent_giftcards', (username)->
        Docs.find   
            model:'giftcard'
            _author_username:username
        
    Meteor.publish 'user_received_giftcards', (username)->
        Docs.find   
            model:'giftcard'
            recipient_username:username
            
            
            
            
            
if Meteor.isClient
    Router.route '/giftcard/:doc_id/edit', (->
        @layout 'layout'
        @render 'giftcard_edit'
        ), name:'giftcard_edit'



    Template.giftcard_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.giftcard_edit.events
        'click .send_giftcard': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    giftcard = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update giftcard._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'giftcard sent',
                        ''
                        'success'
                    Router.go "/giftcard/#{@_id}/"
                    )
            )


            
    Template.giftcard_edit.helpers
        all_shop: ->
            Docs.find
                model:'giftcard'