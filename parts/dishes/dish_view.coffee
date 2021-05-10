if Meteor.isClient
    Router.route '/dish/:doc_id', (->
        @layout 'layout'
        @render 'dish_view'
        ), name:'dish_view'


    Template.dish_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'dish_from_dish_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'orders_from_dish_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_dish_id', Router.current().params.doc_id


    Template.dish_view.events
        'click .mark_ready': ->
            if confirm 'mark dish ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:true
                        ready_timestamp:Date.now()

        'click .unmark_ready': ->
            if confirm 'unmark dish ready?'
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
                    dish = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:@order_price
                    Swal.fire(
                        'refund processed',
                        ''
                        'success'
                    Meteor.call 'calc_dish_data', dish._id, ->
                    Docs.remove @_id
                    )
            )


    Template.dish_view.helpers
        dish_order_total: ->
            orders = 
                Docs.find({
                    model:'order'
                    dish_id:@_id
                }).fetch()
            res = 0
            for order in orders
                res += order.order_price
            res
                

        can_cancel: ->
            dish = Docs.findOne Router.current().params.doc_id
            if Meteor.userId() is dish._author_id
                if dish.ready
                    false
                else
                    true
            else if Meteor.userId() is @_author_id
                if dish.ready
                    false
                else
                    true


        can_order: ->
            if Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                @cook_user_id isnt Meteor.userId()

        dish_order_class: ->
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
        #                 dish_id: Router.current().params.doc_id
        #             Swal.fire(
        #                 'wait list joined',
        #                 "you'll be alerted if accepted"
        #                 'success'
        #             )
        #     )

        'click .order_dish': ->
            # if Meteor.user().credit >= @price_per_serving
            # Docs.insert
            #     model:'order'
            #     status:'pending'
            #     complete:false
            #     dish_id: Router.current().params.doc_id
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
            Meteor.call 'order_dish', @_id, (err, res)->
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
    Meteor.publish 'orders_from_dish_id', (dish_id)->
        # dish = Docs.findOne dish_id
        Docs.find
            model:'order'
            dish_id:dish_id
