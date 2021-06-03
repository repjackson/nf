if Meteor.isClient
    Template.profile_sub_item.onCreated ->
        @autorun => Meteor.subscribe 'product_from_sub_id', @data._id
    Template.user_subs.onCreated ->
        # @autorun => Meteor.subscribe 'user_subs', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'product_subscription'
    Template.user_subs.helpers
        subs: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'product_subscription'
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_subs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'product_subscription'
            _author_id: user._id
        }, 
            limit:10
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_sub_id', (sub_id)->
        sub = Docs.findOne sub_id
        Docs.find
            model:'product'
            _id: sub.product_id
