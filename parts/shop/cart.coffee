if Meteor.isClient
    Router.route '/cart', (->
        @layout 'layout'
        @render 'cart'
        ), name:'cart'

    Template.cart.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'store_session'
        @autorun => Meteor.subscribe 'my_cart'

    Template.cart.helpers
        cart_items: ->
            Docs.find
                model:'cart_item'
                # ingredient_ids: $in: [@_id]


if Meteor.isServer
    Meteor.publish 'my_cart', ->
        Docs.find
            model:'cart_item'
            _author_id: Meteor.userId()