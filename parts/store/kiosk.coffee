Router.route '/kiosk', (->
    @layout 'mlayout'
    @render 'kiosk_container'
    ), name:'kiosk'


Router.route '/store_session/:doc_id', (->
    @layout 'mlayout'
    @render 'store_session'
    ), name:'store_session'

if Meteor.isClient
    Template.kiosk_settings.onCreated ->
        @autorun -> Meteor.subscribe 'kiosk_document'

    Template.kiosk_container.onCreated ->
        @autorun -> Meteor.subscribe 'kiosk_document'

    Template.kiosk_settings.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 3000

    Template.set_kiosk_template.events
        'click .set_kiosk_template': ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            Docs.update kiosk_doc._id,
                $set:kiosk_view:@value





    Template.kiosk_settings.events
        'click .create_kiosk': (e,t)->
            Docs.insert
                model:'kiosk'

        'click .print_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            console.log kiosk

        'click .delete_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk
                if confirm "delete  #{kiosk._id}?"
                    Docs.remove kiosk._id

    Template.kiosk_settings.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view

    Template.kiosk_container.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view


    Template.store_session.onCreated ->
        @autorun => Meteor.subscribe 'current_poll'
        @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
        @autorun => Meteor.subscribe 'checkin_guests',Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'resident_from_store_session', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'store_session', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'model_docs', 'guest'

        # @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    Template.store_session.onRendered ->
        # @timer = new ReactiveVar 5
        # Session.set 'timer',5
        # Session.set 'timer_engaged', false
        # Meteor.setTimeout ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     if store_session_document and store_session_document.user_id
        #         resident = Meteor.users.findOne store_session_document.user_id
        #         # if resident.user_id
        #         rules_found = Docs.findOne
        #             model:'rules_and_regs_signing'
        #             resident:resident.username
        #         if resident.rules_and_regulations_signed and resident.member_waiver_signed
        #             Session.set 'timer_engaged', true
        #             interval_id = Meteor.setInterval( ->
        #                 if Session.equals 'timer_engaged', true
        #                     if Session.equals 'timer', 0
        #                         Meteor.call 'submit_checkin'
        #                         Meteor.clearInterval interval_id
        #                     else
        #                         Session.set('timer', Session.get('timer')-1)
        #                 # t.timer.set(t.timer.get()-1)
        #             ,1000)
        # , 4000
        # Session.set 'loading_checkin', false
        # alert 'stop loading'



    Template.store_session.events
        'click .vote_yes': ->
            $('.poll_area').transition('fade out', 500)
            Meteor.setTimeout =>
                store_session_document = Docs.findOne Router.current().params.doc_id
                Meteor.call 'kiosk_vote_yes', @_id, store_session_document.user_id
            , 500
            $('.poll_area').transition('fade in', 500)

        'click .vote_no': ->
            $('.poll_area').transition('fade out', 500)
            Meteor.setTimeout =>
                store_session_document = Docs.findOne Router.current().params.doc_id
                Meteor.call 'kiosk_vote_no', @_id, store_session_document.user_id
            , 500
            $('.poll_area').transition('fade in', 500)


        'click .cancel_checkin': ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            if store_session_document
                Docs.remove store_session_document._id
            if store_session_document and store_session_document.user_id
                Meteor.users.update store_session_document.user_id,
                    $inc:
                        checkins_without_email_verification:-1
                        checkins_without_gov_id:-1

            Router.go "/store"

        # 'click .recheck_photo': ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     if store_session_document and store_session_document.user_id
        #         user = Meteor.users.findOne store_session_document.user_id
        #         Meteor.call 'image_check', user
        #         Meteor.call 'staff_government_id_check', user
        #
        #
        #
        # 'click .recheck': ->
        #     console.log @
        #     Meteor.call 'run_user_checks', @
        #     Meteor.call 'member_waiver_signed', @
        #     Meteor.call 'rules_and_regulations_signed', @

        'click .add_guest': ->
            # console.log @
            store_session_document = Docs.findOne Router.current().params.doc_id
            new_guest_id =
                Docs.insert
                    model:'guest'
                    session_id: store_session_document._id
                    resident_id: store_session_document.user_id
                    resident: store_session_document.resident_username
            # Session.set 'displaying_profile', null
            #
            Router.go "/add_guest/#{new_guest_id}"

        'click .sign_rules': ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'rules_and_regs_signing'
                session_id: store_session_document._id
                resident_id: store_session_document.user_id
                resident: store_session_document.resident_username
            Router.go "/sign_rules/#{new_id}/#{store_session_document.resident_username}"
            # Session.set 'displaying_profile',null


        'click .sign_guidelines': ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'member_guidelines_signing'
                session_id: store_session_document._id
                resident_id: store_session_document.user_id
                resident: store_session_document.resident_username
            Router.go "/sign_guidelines/#{new_id}/#{store_session_document.resident_username}"
            # Session.set 'displaying_profile',null

        'click .add_recent_guest': ->
            current_session = Docs.findOne
                model:'store_session'
                current:true
            Docs.update current_session._id,
                $addToSet:guest_ids:@_id

        'click .remove_guest': ->
            current_session = Docs.findOne
                model:'store_session'
                current:true
            # console.log current_session
            Docs.update current_session._id,
                $pull:guest_ids:@_id

        'click .toggle_adding_guest': ->
            Session.set 'adding_guest', true
            Session.set 'timer_engaged', false

        'click .submit_checkin': (e,t)->
            Meteor.call 'submit_checkin'

        'click .cancel_auto_checkin': (e,t)->
            Session.set 'timer_engaged',false

    Template.store_session.helpers
        current_poll: ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            # store_session_document.user_id

            Docs.findOne
                model:'vote'
                upvoter_ids: $nin:[store_session_document.user_id]
                downvoter_ids: $nin:[store_session_document.user_id]



        timer_engaged: ->
            Session.get 'timer_engaged'
        timer: ->
            Session.get 'timer'
            # console.log Template.instance()
            # Template.instance().timer.get()

        rules_signed: ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            if store_session_document.user_id
                resident = Meteor.users.findOne store_session_document.user_id
                # if resident.user_id
                Docs.findOne
                    model:'rules_and_regs_signing'
                    resident:resident.username
        session_document: -> Docs.findOne Router.current().params.doc_id

        adding_guests: -> Session.get 'adding_guest'
        checking_in_doc: ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            # console.log store_session_document
            store_session_document
        checkin_guest_docs: () ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            Docs.find
                _id:$in:store_session_document.guest_ids

        user: ->
            store_session_document = Docs.findOne Router.current().params.doc_id
            if store_session_document and store_session_document.user_id
                Meteor.users.findOne store_session_document.user_id


    Template.resident_guest.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data
    Template.resident_guest.helpers
        guest_doc: ->
            Docs.findOne Template.currentData()


    Template.store_stats.events
        'click .recalc': ->
            console.log @
            Meteor.call 'recalc_store_stats', @user



if Meteor.isServer
    Meteor.publish 'kiosk_document', ()->
        Docs.find
            model:'kiosk'

    Meteor.methods
        kiosk_vote_no: (poll_id, user_id)->
            console.log poll_id, user_id
            Docs.update poll_id,
                $addToSet: downvoter_ids: user_id
        kiosk_vote_yes: (poll_id, user_id)->
            console.log poll_id, user_id
            Docs.update poll_id,
                $addToSet: upvoter_ids: user_id


        recalc_store_stats: (user)->
            # console.log user
            session_count =
                Docs.find(
                    model:'store_session'
                    user_id:user._id
                ).count()
            # console.log session_count
            Meteor.users.update user._id,
                $set:total_session_count:session_count
            sorted_session_count =
                Meteor.users.find({
                    total_session_count:$exists:1
                },
                    sort:total_session_count:-1
                    fields:
                        username:1
                        total_session_count:1
                ).fetch()
            # console.log total_top_ten
            found_in_ranking = _.findWhere(sorted_session_count,{username:user.username})
            console.log 'found', found_in_ranking
            global_rank = _.indexOf(sorted_session_count,found_in_ranking)+1
            if global_rank > 0
                Meteor.users.update user._id,
                    $set:global_rank:global_rank

    publishComposite 'store_session', (doc_id)->
        {
            find: ->
                Docs.find doc_id
            children: [
                { find: (doc) ->
                    Meteor.users.find
                        _id: doc.user_id
                    }
                { find: (doc) ->
                    Docs.find
                        model: 'guest'
                        _id:doc.guest_ids
                    }
                ]
        }