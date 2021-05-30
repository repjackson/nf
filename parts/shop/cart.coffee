if Meteor.isClient
    Router.route '/cart', (->
        @layout 'layout'
        @render 'cart'
        ), name:'cart'

    Template.cart.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'store_session'
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.cart.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                ingredient_ids: $in: [@_id]
