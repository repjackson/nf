if Meteor.isClient
    Router.route '/orders', (->
        @render 'orders'
        ), name:'orders'

                        
                
if Meteor.isClient
    Template.orders.onCreated ->
        @autorun -> Meteor.subscribe 'orders',
            Session.get('order_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.orders.helpers
        orders: ->
            match = {model:'order'}
            if Session.get('order_status_filter')
                match.status = Session.get('order_status_filter')
            if Session.get('order_delivery_filter')
                match.delivery_method = Session.get('order_sort_filter')
            if Session.get('order_sort_filter')
                match.delivery_method = Session.get('order_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


    Router.route '/order/:doc_id', (->
        @layout 'layout'
        @render 'order'
        ), name:'order'
    Router.route '/order/:doc_id/view', (->
        @layout 'layout'
        @render 'order'
        ), name:'order_long'


    Template.order.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_order_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'order_things', Router.current().params.doc_id


                
            
            
    Template.order.events
        'click .mark_viewed': ->
            # if confirm 'mark viewed?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    runner_viewed: true
                    runner_viewed_timestamp: Date.now()
                    runner_username: Meteor.user().username
                    status: 'viewed' 
      
        'click .mark_preparing': ->
            # if confirm 'mark mark_preparing?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    preparing: true
                    preparing_timestamp: Date.now()
                    status: 'preparing' 
       
        'click .mark_prepared': ->
            # if confirm 'mark prepared?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    prepared: true
                    prepared_timestamp: Date.now()
                    status: 'prepared' 
     
        'click .mark_arrived': ->
            # if confirm 'mark arrived?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    arrived: true
                    arrived_timestamp: Date.now()
                    status: 'arrived' 
        
        'click .mark_delivering': ->
            # if confirm 'mark delivering?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivering: true
                    delivering_timestamp: Date.now()
                    status: 'delivering' 
      
        'click .mark_delivered': ->
            # if confirm 'mark delivered?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivered: true
                    delivered_timestamp: Date.now()
                    status: 'delivered' 
      
        'click .delete_order': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/orders"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'order_event'
                    order_id: Router.current().params.doc_id
                    order_status:'ready'


    Template.order.helpers
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
    Meteor.publish 'orders', (order_id, status)->
        # order = Docs.findOne order_id
        match = {model:'order', app:'nf'}
        if status 
            match.status = status

        Docs.find match, limit:20
        
    Meteor.publish 'product_by_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find
            _id: order.product_id
    Meteor.publish 'order_things', (order_id)->
        order = Docs.findOne order_id
        Docs.find
            model:'thing'
            order_id: order_id

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



if Meteor.isClient
    Template.user_order_item.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_order_id', @data._id
    Template.user_orders.onCreated ->
        @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.user_orders.helpers
        orders: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'order'
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_orders', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'order'
            _author_id: user._id
        }, 
            limit:10
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find
            model:'product'
            _id: order.product_id