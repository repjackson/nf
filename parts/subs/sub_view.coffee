if Meteor.isClient
    Router.route '/sub/:doc_id', (->
        @layout 'layout'
        @render 'sub_view'
        ), name:'sub_view'


    Template.sub_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'product'
        # @autorun => Meteor.subscribe 'model_docs', 'sub'
        @autorun => Meteor.subscribe 'product_by_sub_id', Router.current().params.doc_id


    Template.sub_view.events
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'sub_event'
                    sub_id: Router.current().params.doc_id
                    sub_status:'ready'
        'click .unsub': ->
            if confirm 'cancel?'
                Docs.remove @_id
                Router.go "/product/#{@product_id}"


    Template.sub_view.helpers
        can_sub: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                sub_count =
                    Docs.find(
                        model:'sub'
                        sub_id:@_id
                    ).count()
                if sub_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'product_by_sub_id', (sub_id)->
        sub = Docs.findOne sub_id
        Docs.find
            _id: sub.product_id

    # Meteor.methods
        # sub_sub: (sub_id)->
        #     sub = Docs.findOne sub_id
        #     Docs.insert
        #         model:'sub'
        #         sub_id: sub._id
        #         sub_price: sub.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-sub.price_per_serving
        #     Meteor.users.update sub._author_id,
        #         $inc:credit:sub.price_per_serving
        #     Meteor.call 'calc_sub_data', sub_id, ->
