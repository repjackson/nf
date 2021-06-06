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
        @autorun => Meteor.subscribe 'product_source', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'product_from_product_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'orders_from_product_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'subs_from_product_id', Router.current().params.doc_id
    Template.product_layout.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id
    Template.product_layout.events
        'click .goto_source': (e,t)->
            $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Router.current().params.doc_id
            Meteor.setTimeout =>
                Router.go "/source/#{product.source_id}"
            , 240
        
        'click .add_to_cart': ->
            Meteor.call 'add_to_cart', @_id, =>
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{@title} added"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )


    Template.product_subscriptions.events
        'click .subscribe': ->
            if confirm 'subscribe?'
                Docs.update Router.current().params.doc_id,
                    $addToSet: 
                        subscribed_ids: Meteor.userId()
                new_sub_id = 
                    Docs.insert 
                        model:'product_subscription'
                        product_id:Router.current().params.doc_id
                Router.go "/subscription/#{new_sub_id}/edit"
                    
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

    Template.product_inventory.onCreated ->
        @autorun => Meteor.subscribe 'inventory_from_product_id', Router.current().params.doc_id
            
    Template.product_inventory.events
        'click .add_inventory': ->
            count = Docs.find(model:'inventory_item').count()
            new_id = Docs.insert 
                model:'inventory_item'
                product_id:@_id
                id:count++
            Session.set('editing_inventory_id', @_id)
        'click .edit_inventory_item': -> 
            Session.set('editing_inventory_id', @_id)
        'click .save_inventory_item': -> 
            Session.set('editing_inventory_id', null)
        
    Template.product_inventory.helpers
        editing_this: ->
            Session.equals('editing_inventory_id', @_id)
        inventory_items: ->
            Docs.find 
                model:'inventory_item'
                product_id:@_id
            


    Template.product_subscriptions.helpers
        product_subs: ->
            Docs.find
                model:'product_subscription'
                product_id:Router.current().params.doc_id

    Template.product_layout.helpers
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
    Meteor.publish 'product_source', (product_id)->
        product = Docs.findOne product_id
        # console.log 'need source from this product', product
        Docs.find
            model:'source'
            _id:product.source_id
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
    Meteor.publish 'inventory_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'inventory_item'
            product_id:product_id





if Meteor.isClient
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'



    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'

    Template.product_edit.onRendered ->
        Meteor.setTimeout ->
            today = new Date()
            $('#availability')
                .calendar({
                    inline:true
                    # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
                    # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
                })
        , 2000

    Template.product_edit.helpers
        all_shop: ->
            Docs.find
                model:'product'
        can_delete: ->
            product = Docs.findOne Router.current().params.doc_id
            if product.reservation_ids
                if product.reservation_ids.length > 1
                    false
                else
                    true
            else
                true

    Template.product_edit.onCreated ->
        @autorun => @subscribe 'source_search_results', Session.get('source_search'), ->
    Template.product_edit.helpers
        search_results: ->
            Docs.find 
                model:'source'
                

    Template.product_edit.events
        'click .remove_source': (e,t)->
            if confirm 'remove source?'
                Docs.update Router.current().params.doc_id,
                    $set:source_id:null
        'click .pick_source': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:source_id:@_id
        'keyup .source_search': (e,t)->
            # if e.which is '13'
            val = t.$('.source_search').val()
            console.log val
            Session.set('source_search', val)
                
            
        'click .save_product': ->
            product_id = Router.current().params.doc_id
            Meteor.call 'calc_product_data', product_id, ->
            Router.go "/product/#{product_id}"


        'click .save_availability': ->
            doc_id = Router.current().params.doc_id
            availability = $('.ui.calendar').calendar('get date')[0]
            console.log availability
            formatted = moment(availability).format("YYYY-MM-DD[T]HH:mm")
            console.log formatted
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
            Docs.update doc_id,
                $set:datetime_available:formatted





        # 'click .select_product': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             product_id: @_id
        #
        #
        # 'click .clear_product': ->
        #     if confirm 'clear product?'
        #         Docs.update Router.current().params.doc_id,
        #             $set:
        #                 product_id: null



        'click .delete_product': ->
            if confirm 'refund orders and cancel product?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"

if Meteor.isServer 
    Meteor.publish 'source_search_results', (source_title_queary)->
        Docs.find 
            model:'source'
            title: {$regex:"#{source_title_queary}",$options:'i'}
