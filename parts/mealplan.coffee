if Meteor.isClient
    Router.route '/mealplans', (->
        @layout 'layout'
        @render 'mealplans'
        ), name:'mealplans'
    Router.route '/user/:username/mealplans', (->
        @layout 'user_layout'
        @render 'user_mealplans'
        ), name:'user_mealplans'
    Router.route '/mealplan/:doc_id', (->
        @layout 'layout'
        @render 'mealplan_view'
        ), name:'mealplan_view'
    Router.route '/mealplan/:doc_id/view', (->
        @layout 'layout'
        @render 'mealplan_view'
        ), name:'mealplan_view_long'
    Router.route '/product/:doc_id/mealplans', (->
        @layout 'product_layout'
        @render 'product_mealplans'
        ), name:'product_mealplans'
    
    
    Template.mealplans.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'mealplan', ->
            
            
    Template.product_mealplans.onCreated ->
        @autorun => Meteor.subscribe 'product_mealplans', Router.current().params.doc_id, ->
    Template.user_mealplans.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_mealplans', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_mealplans', Router.current().params.username, ->
            
    Template.mealplan_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.mealplan_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    

    Template.mealplan_view.helpers
        is_cook: -> Meteor.userId() in @cook_ids
        is_fav: -> Meteor.userId() in @favorite_user_ids
    Template.mealplan_view.events
        'click .mark_cook': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: cook_ids:Meteor.userId()
            $('body').toast(
                showIcon: 'food'
                message: "marked cooked"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
        'click .unmark_cook': ->
            Docs.update Router.current().params.doc_id, 
                $pull: cook_ids:Meteor.userId()
       
        'click .mark_fav': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: favorite_user_ids:Meteor.userId()
            $('body').toast(
                showIcon: 'heart'
                message: "marked favorite"
                showProgress: 'bottom'
                class: 'error'
                # displayTime: 'auto',
                position: "bottom right"
            )
        'click .unmark_fav': ->
            Docs.update Router.current().params.doc_id, 
                $pull: favorite_user_ids:Meteor.userId()

    Template.mealplans.events
        'click .add_mealplan': ->
            new_id = Docs.insert 
                model:'mealplan'
            Router.go "/mealplan/#{new_id}/edit"    
    
    Template.product_mealplans.events
        'click .add_mealplan': ->
            new_id = Docs.insert 
                model:'mealplan'
                product_id:Router.current().params.doc_id
            Router.go "/mealplan/#{new_id}/edit"    
                
    Template.user_mealplans.events
        'click .send_mealplan': ->
            new_id = 
                Docs.insert 
                    model:'mealplan'
            
            Router.go "/mealplan/#{new_id}/edit"
            
            
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
            
           
           
            
    Template.user_mealplans.helpers
        sent_mealplans: ()->
            Docs.find   
                model:'mealplan'
                _author_username:Router.current().params.username
        received_mealplans: ()->
            Docs.find   
                model:'mealplan'
                recipient_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_mealplans', (username)->
        Docs.find   
            model:'mealplan'
            recipient_username:username
            
            
    Meteor.publish 'user_sent_mealplans', (username)->
        Docs.find   
            model:'mealplan'
            _author_username:username
    Meteor.publish 'product_mealplans', (product_id)->
        Docs.find   
            model:'mealplan'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/mealplan/:doc_id/edit', (->
        @layout 'layout'
        @render 'mealplan_edit'
        ), name:'mealplan_edit'



    Template.mealplan_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.mealplan_edit.events
        'click .send_mealplan': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    mealplan = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update mealplan._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'mealplan sent',
                        ''
                        'success'
                    Router.go "/mealplan/#{@_id}/"
                    )
            )

        'click .delete_mealplan':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/mealplans"
            
    Template.mealplan_edit.helpers
        all_shop: ->
            Docs.find
                model:'mealplan'