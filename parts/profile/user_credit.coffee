if Meteor.isClient
    Template.user_credit.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # @autorun => Meteor.subscribe 'my_topups'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Meteor.users.findOne username:Router.current().params.username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Meteor.users.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    # Template.user_credit.events
    #     'click .add_credits': ->
    #         amount = parseInt $('.deposit_amount').val()
    #         amount_times_100 = parseInt amount*100
    #         calculated_amount = amount_times_100*1.02+20
    #         # Template.instance().checkout.open
    #         #     name: 'credit deposit'
    #         #     # email:Meteor.user().emails[0].address
    #         #     description: 'gold run'
    #         #     amount: calculated_amount
    #         Docs.insert
    #             model:'deposit'
    #             amount: amount
    #         Meteor.users.update Meteor.userId(),
    #             $inc: credit: amount_times_100


    #     'click .initial_withdrawal': ->
    #         withdrawal_amount = parseInt $('.withdrawal_amount').val()
    #         if confirm "initiate withdrawal for #{withdrawal_amount}?"
    #             Docs.insert
    #                 model:'withdrawal'
    #                 amount: withdrawal_amount
    #                 status: 'started'
    #                 complete: false
    #             Meteor.users.update Meteor.userId(),
    #                 $inc: credit: -withdrawal_amount

    #     'click .cancel_withdrawal': ->
    #         if confirm "cancel withdrawal for #{@amount}?"
    #             Docs.remove @_id
    #             Meteor.users.update Meteor.userId(),
    #                 $inc: credit: @amount



    Template.user_credit.helpers
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        topups: ->
            Docs.find {
                model:'balance_topup'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1




    Template.user_credit.events
        'click .add_credit': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.update Meteor.userId(),
                $inc:credit:1
                # $set:credit:1
        'click .remove_credit': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.update Meteor.userId(),
                $inc:credit:-1
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount



    Template.user_dashboard.onCreated ->
        # @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.user_dashboard.helpers

    Template.user_dashboard.events
            
            
if Meteor.isServer
    Meteor.publish 'my_topups', ->
        Docs.find 
            model:'balance_topup'
            _author_id:Meteor.userId()