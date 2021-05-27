if Meteor.isClient
    Template.profile_order_item.onCreated ->
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
