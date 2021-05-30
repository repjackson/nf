if Meteor.isClient
    Router.route '/product/:doc_id', (->
        @layout 'product_layout'
        @render 'product_main'
        ), name:'product_main'
    Router.route '/product/:doc_id/orders', (->
        @layout 'product_layout'
        @render 'product_orders'
        ), name:'product_orders'
    Router.route '/product/:doc_id/subscriptions', (->
        @layout 'product_layout'
        @render 'product_subscriptions'
        ), name:'product_subscriptions'
    Router.route '/product/:doc_id/recipes', (->
        @layout 'product_layout'
        @render 'product_recipes'
        ), name:'product_recipes'
    Router.route '/product/:doc_id/comments', (->
        @layout 'product_layout'
        @render 'product_comments'
        ), name:'product_comments'
    Router.route '/product/:doc_id/reviews', (->
        @layout 'product_layout'
        @render 'product_reviews'
        ), name:'product_reviews'
    Router.route '/product/:doc_id/inventory', (->
        @layout 'product_layout'
        @render 'product_inventory'
        ), name:'product_inventory'


    Template.product_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'product_from_product_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'orders_from_product_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'subs_from_product_id', Router.current().params.doc_id
    Template.product_layout.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id


    Template.product_layout.events
        'click .subscribe': ->
            if confirm 'subscribe?'
                Docs.update Router.current().params.doc_id,
                    $addToSet: 
                        subscribed_ids: Meteor.userId()
                Docs.insert 
                    model:'product_subscription'
                    product_id:Router.current().params.doc_id
        'click .unsubscribe': ->
            if confirm 'unsubscribe?'
                Docs.update Router.current().params.doc_id,
                    $pull: 
                        subscribed_ids: Meteor.userId()
                                    
    
        'click .mark_ready': ->
            if confirm 'mark product ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:true
                        ready_timestamp:Date.now()

        'click .unmark_ready': ->
            if confirm 'unmark product ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:false
                        ready_timestamp:null

        'click .cancel_order': ->
            Swal.fire({
                title: 'confirm cancel'
                text: "this will refund you #{@order_price} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    product = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:@order_price
                    Swal.fire(
                        'refund processed',
                        ''
                        'success'
                    Meteor.call 'calc_product_data', product._id, ->
                    Docs.remove @_id
                    )
            )


    Template.product_layout.helpers
        product_subs: ->
            Docs.find
                model:'product_subscription'
                product_id:Router.current().params.doc_id

        product_order_total: ->
            orders = 
                Docs.find({
                    model:'order'
                    product_id:@_id
                }).fetch()
            res = 0
            for order in orders
                res += order.order_price
            res
                

        can_cancel: ->
            product = Docs.findOne Router.current().params.doc_id
            if Meteor.userId() is product._author_id
                if product.ready
                    false
                else
                    true
            else if Meteor.userId() is @_author_id
                if product.ready
                    false
                else
                    true


        can_order: ->
            if Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                @cook_user_id isnt Meteor.userId()

        product_order_class: ->
            if @status is 'ready'
                'green'
            else if @status is 'pending'
                'yellow'
                
                
    Template.order_button.onCreated ->

    Template.order_button.helpers

    Template.order_button.events
        # 'click .join_waitlist': ->
        #     Swal.fire({
        #         title: 'confirm wait list join',
        #         text: 'this will charge your account if orders cancel'
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             Docs.insert
        #                 model:'order'
        #                 waitlist:true
        #                 product_id: Router.current().params.doc_id
        #             Swal.fire(
        #                 'wait list joined',
        #                 "you'll be alerted if accepted"
        #                 'success'
        #             )
        #     )

        'click .order_product': ->
            # if Meteor.user().credit >= @price_per_serving
            # Docs.insert
            #     model:'order'
            #     status:'pending'
            #     complete:false
            #     product_id: Router.current().params.doc_id
            #     if @serving_unit
            #         serving_text = @serving_unit
            #     else
            #         serving_text = 'serving'
            # Swal.fire({
            #     # title: "confirm buy #{serving_text}"
            #     title: "confirm order?"
            #     text: "this will charge you #{@price_usd}"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result) =>
            #     if result.value
            Meteor.call 'order_product', @_id, (err, res)->
                if err
                    Swal.fire(
                        'err'
                        'error'
                    )
                    console.log err
                else
                    Router.go "/order/#{res}/edit"
                    # Swal.fire(
                    #     'order and payment processed'
                    #     ''
                    #     'success'
                    # )
        # )

if Meteor.isServer
    Meteor.publish 'orders_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'order'
            product_id:product_id
            
    Meteor.publish 'subs_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'product_subscription'
            product_id:product_id
