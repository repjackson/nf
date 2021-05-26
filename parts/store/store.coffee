if Meteor.isClient
    Router.route '/store/', (->
        @layout 'layout'
        @render 'store'
        ), name:'store'

    Template.store.onCreated ->
        @autorun => Meteor.subscribe 'checkedin_customers'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable

    Template.store.helpers
        donations: ->
            Docs.find {
                model:'donation'
            }, _timestamp:1
    Template.store.events
        'click .start_donation': ->
            donation_amount = parseInt $('.store_amount').val()*100
            Template.instance().checkout.open
                name: 'mmm donation'
                # email:Meteor.user().emails[0].address
                # description: 'mmm donation'
                amount: donation_amount