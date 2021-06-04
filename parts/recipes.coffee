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
    
    Template.recipes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'recipe', ->
            
            
    Template.user_recipes.onCreated ->
        @autorun => Meteor.subscribe 'user_sent_recipes', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'user_received_recipes', Router.current().params.username, ->
            
    Template.recipe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.recipe_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    

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


            
    Template.recipe_edit.helpers
        all_shop: ->
            Docs.find
                model:'recipe'