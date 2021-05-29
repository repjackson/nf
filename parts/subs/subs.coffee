if Meteor.isClient
    Router.route '/subs', (->
        @render 'subs'
        ), name:'subs'

    Template.subs.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'service'
        # @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'menu_section'
        @autorun -> Meteor.subscribe 'model_docs', 'product_subscription'
        @autorun -> Meteor.subscribe 'model_docs', 'product'
        # @autorun -> Meteor.subscribe 'users'

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.subs.helpers
        subs: ->
            match = {model:'product_subscription'}
            # if Session.get('sub_delivery_filter')
            #     match.delivery_method = Session.get('sub_sort_filter')
            # if Session.get('sub_sort_filter')
            #     match.delivery_method = Session.get('sub_sort_filter')
            Docs.find match,
                sort: _timestamp:-1