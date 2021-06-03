if Meteor.isClient
    Router.route '/sub/:doc_id/edit', (->
        @layout 'layout'
        @render 'sub_edit'
        ), name:'sub_edit'
    Router.route '/subscription/:doc_id/edit', (->
        @layout 'layout'
        @render 'sub_edit'
        ), name:'sub_edit_long'



    Template.sub_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_from_sub_id', Router.current().params.doc_id 

    Template.sub_edit.helpers
        all_shop: ->
            Docs.find
                model:'product'
        can_delete: ->
            sub = Docs.findOne Router.current().params.doc_id
            if sub.reservation_ids
                if sub.reservation_ids.length > 1
                    false
                else
                    true
            else
                true


    Template.sub_edit.events
        'click .select_product': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    product_id: @_id


        'click .delete_sub': ->
            if confirm 'refund subs and cancel sub?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"
