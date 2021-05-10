if Meteor.isClient
    Router.route '/order/:doc_id/edit', (->
        @layout 'layout'
        @render 'order_edit'
        ), name:'order_edit'



    Template.order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'dish_from_order_id', Router.current().params.doc_id 

    Template.order_edit.helpers
        all_dishes: ->
            Docs.find
                model:'dish'
        can_delete: ->
            order = Docs.findOne Router.current().params.doc_id
            if order.reservation_ids
                if order.reservation_ids.length > 1
                    false
                else
                    true
            else
                true


    Template.order_edit.events
        'click .select_dish': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    dish_id: @_id


        'click .delete_order': ->
            if confirm 'refund orders and cancel order?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"
