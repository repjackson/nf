if Meteor.isClient
    Router.route '/recipes', (->
        @layout 'layout'
        @render 'recipes'
        ), name:'recipes'
    Router.route '/user/:username/recipes', (->
        @layout 'user_layout'
        @render 'user_recipes'
        ), name:'user_recipes'
    Router.route '/recipe/:doc_id', (->
        @layout 'layout'
        @render 'recipe_view'
        ), name:'recipe_view'
    Router.route '/recipe/:doc_id/view', (->
        @layout 'layout'
        @render 'recipe_view'
        ), name:'recipe_view_long'
    Router.route '/product/:doc_id/recipes', (->
        @layout 'product_layout'
        @render 'product_recipes'
        ), name:'product_recipes'
    
    
    Template.recipes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'recipe', ->
            
            
    Template.product_recipes.onCreated ->
        @autorun => Meteor.subscribe 'product_recipes', Router.current().params.doc_id, ->
    Template.user_recipes.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_recipes', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_recipes', Router.current().params.username, ->
            
    Template.recipe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.recipe_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    

    Template.recipe_view.helpers
        is_cook: -> Meteor.userId() in @cook_ids
        is_fav: -> Meteor.userId() in @favorite_user_ids
    Template.recipe_view.events
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

    Template.recipes.events
        'click .add_recipe': ->
            new_id = Docs.insert 
                model:'recipe'
            Router.go "/recipe/#{new_id}/edit"    
    
    Template.product_recipes.events
        'click .add_recipe': ->
            new_id = Docs.insert 
                model:'recipe'
                product_id:Router.current().params.doc_id
            Router.go "/recipe/#{new_id}/edit"    
                
    Template.user_recipes.events
        'click .send_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
            
            Router.go "/recipe/#{new_id}/edit"
            
            
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
            
           
           
            
    Template.user_recipes.helpers
        sent_recipes: ()->
            Docs.find   
                model:'recipe'
                _author_username:Router.current().params.username
        received_recipes: ()->
            Docs.find   
                model:'recipe'
                recipient_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.publish 'user_received_recipes', (username)->
        Docs.find   
            model:'recipe'
            recipient_username:username
            
            
    Meteor.publish 'user_sent_recipes', (username)->
        Docs.find   
            model:'recipe'
            _author_username:username
    Meteor.publish 'product_recipes', (product_id)->
        Docs.find   
            model:'recipe'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/recipe/:doc_id/edit', (->
        @layout 'layout'
        @render 'recipe_edit'
        ), name:'recipe_edit'



    Template.recipe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.recipe_edit.events
        'click .send_recipe': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    recipe = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update recipe._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'recipe sent',
                        ''
                        'success'
                    Router.go "/recipe/#{@_id}/"
                    )
            )

        'click .delete_recipe':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/recipes"
            
    Template.recipe_edit.helpers
        all_shop: ->
            Docs.find
                model:'recipe'