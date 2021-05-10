if Meteor.isClient
    Router.route '/orders', (->
        @render 'orders'
        ), name:'orders'

    Template.orders.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
        # @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'menu_section'
        @autorun -> Meteor.subscribe 'model_docs', 'order'
        @autorun -> Meteor.subscribe 'model_docs', 'dish'
        # @autorun -> Meteor.subscribe 'users'

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.orders.helpers
        orders: ->
            match = {model:'order'}
            if Session.get('order_delivery_filter')
                match.delivery_method = Session.get('order_sort_filter')
            if Session.get('order_sort_filter')
                match.delivery_method = Session.get('order_sort_filter')
            Docs.find match,
                sort: _timestamp:-1