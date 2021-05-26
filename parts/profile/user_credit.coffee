if Meteor.isClient
    Template.user_credit.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
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
        owner_earnings: ->
            Docs.find
                model:'reservation'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1





    # Template.user_reservations.onCreated ->
    #     @autorun => Meteor.subscribe 'user_reservations', Router.current().params.username
    #     @autorun => Meteor.subscribe 'model_docs', 'rental'
    # Template.user_reservations.helpers
    #     reservations: ->
    #         current_user = Meteor.users.findOne username:Router.current().params.username
    #         Docs.find {
    #             model:'reservation'
    #         }, sort:_timestamp:-1


    Template.user_credit.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                user = Meteor.users.findOne username:Router.current().params.username
                deposit_amount = parseInt $('.deposit_amount').val()*100
                stripe_charge = deposit_amount*100*1.02+20
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                charge =
                    amount: deposit_amount*1.02+20
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'deposit'
                            deposit_amount:deposit_amount/100
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update user._id,
                            $inc: credit: deposit_amount*1.05/100
    	)


    Template.user_credit.events
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: calculated_amount

        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount



    Template.user_credit.helpers
        owner_earnings: ->
            Docs.find
                model:'reservation'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1





    Template.user_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
        @autorun => Meteor.subscribe 'user_handling', Router.current().params.username
        @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.user_dashboard.helpers
        current_reservations: ->
            Docs.find
                model:'reservation'
                user_username:Router.current().params.username
        upcoming_reservations: ->
            Docs.find
                model:'reservation'
                user_username:Router.current().params.username
        current_handling_rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'rental'
                handler_username:current_user.username
        current_interest_rate: ->
            interest_rate = 0
            if Meteor.user().handling_active
                current_user = Meteor.users.findOne username:Router.current().params.username
                handling_rentals = Docs.find(
                    model:'rental'
                    handler_username:current_user.username
                ).fetch()
                for handling in handling_rentals
                    interest_rate += handling.hourly_dollars*.1
            if interest_rate
                interest_rate.toFixed(2)


    Template.user_dashboard.events
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username