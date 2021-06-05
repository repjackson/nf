if Meteor.isClient
    Router.route '/store/', (->
        @layout 'layout'
        @render 'store'
        ), name:'store'

    Template.store.onCreated ->
        @autorun => Meteor.subscribe 'store_sessions'
        @autorun => Meteor.subscribe 'model_docs', 'product'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable

    Template.store.helpers
        store_sessions: ->
            Docs.find {
                model:'store_session'
            }, _timestamp:1
            
            
            
    Template.store.events
        'click .new_store_session': ->
            new_session_id = Docs.insert 
                model:'store_session'
                status:'open'
                open:true
                
                
            Router.go "/store_session/#{new_session_id}"
            
            
            
if Meteor.isServer
    Meteor.publish 'store_sessions', ->
        Docs.find 
            model:'store_session'
            