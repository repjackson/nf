if Meteor.isClient
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'
    Router.route '/ingredient/:doc_id/edit', (->
        @layout 'layout'
        @render 'ingredient_edit'
        ), name:'ingredient_edit'
    Router.route '/ingredient/:doc_id/view', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'


    Template.ingredients.events
        'click .add_ingredient': ->
            new_id = 
                Docs.insert     
                    model:'ingredient'
            Router.go "/ingredient/#{new_id}/edit"
            
            
    Template.ingredients.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'ingredient', ->
    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.ingredient_view.helpers
        ingredient_products: ->
            Docs.find
                model:'product'
                ingredient_ids: $in: [@_id]
