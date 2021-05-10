if Meteor.isClient
    Router.route '/order/:doc_id', (->
        @layout 'layout'
        @render 'order_view'
        ), name:'order_view'


    Template.order_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dish'
        # @autorun => Meteor.subscribe 'model_docs', 'order'
        @autorun => Meteor.subscribe 'dish_by_order_id', Router.current().params.doc_id


    Template.order_view.events
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'order_event'
                    order_id: Router.current().params.doc_id
                    order_status:'ready'
        'click .cancel_order': ->
            if confirm 'cancel?'
                Docs.remove @_id
                Router.go "/"


    Template.order_view.helpers
        can_order: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                order_count =
                    Docs.find(
                        model:'order'
                        order_id:@_id
                    ).count()
                if order_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'dish_by_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find
            _id: order.dish_id

    # Meteor.methods
        # order_order: (order_id)->
        #     order = Docs.findOne order_id
        #     Docs.insert
        #         model:'order'
        #         order_id: order._id
        #         order_price: order.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-order.price_per_serving
        #     Meteor.users.update order._author_id,
        #         $inc:credit:order.price_per_serving
        #     Meteor.call 'calc_order_data', order_id, ->
