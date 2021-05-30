# Quagga = require('quagga').default; 

if Meteor.isClient
    Quagga = require('quagga')
    # console.log Quagga
    Router.route '/store_session/:doc_id', (->
        @layout 'layout'
        @render 'store_session'
        ), name:'store_session'

    Template.store_session.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'session_products', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
        # @autorun => Meteor.subscribe 'checkin_guests',Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'resident_from_store_session', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'store_session', Router.current().params.doc_id
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
        'click .close_barcode': ->
            Session.set('view_barcode', false)
        'click .init': ->
            Session.set('view_barcode', true)
            Meteor.setTimeout ->
                Quagga.init({
                    inputStream : {
                      name : "Live",
                      type : "LiveStream",
                      target: document.querySelector('#barcode')
                    },
                    decoder : {
                        readers : ["code_128_reader"]
                        debug: {
                            drawBoundingBox: true,
                            showFrequency: true,
                            drawScanline: true,
                            showPattern: true
                        }
                    }
                  }, (err)->
                      if err
                          console.log(err);
                      console.log("Initialization finished. Ready to start");
                      Quagga.start();
                  );
            , 1000
            
        # 'click .vote_yes': ->
        #     $('.poll_area').transition('fade out', 500)
        #     Meteor.setTimeout =>
        #         store_session_document = Docs.findOne Router.current().params.doc_id
        #         Meteor.call 'kiosk_vote_yes', @_id, store_session_document.user_id
        #     , 500
        #     $('.poll_area').transition('fade in', 500)

        # 'click .vote_no': ->
        #     $('.poll_area').transition('fade out', 500)
        #     Meteor.setTimeout =>
        #         store_session_document = Docs.findOne Router.current().params.doc_id
        #         Meteor.call 'kiosk_vote_no', @_id, store_session_document.user_id
        #     , 500
        #     $('.poll_area').transition('fade in', 500)


        'click .end_session': ->
            if confirm 'end session?'
                Docs.update @_id,
                    $set: 
                        status:'closed'
                        closed:true
                        open:false
                Router.go '/store'
                
                
        'click .reopen_session': ->
            if confirm 'reopen session?'
                Docs.update @_id,
                    $set: 
                        status:'open'
                        closed:false
                        open:true
                
                
        # 'click .cancel_checkin': ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     if store_session_document
        #         Docs.remove store_session_document._id
        #     if store_session_document and store_session_document.user_id
        #         Meteor.users.update store_session_document.user_id,
        #             $inc:
        #                 checkins_without_email_verification:-1
        #                 checkins_without_gov_id:-1

        #     Router.go "/store"

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

        # 'click .add_guest': ->
        #     # console.log @
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     new_guest_id =
        #         Docs.insert
        #             model:'guest'
        #             session_id: store_session_document._id
        #             resident_id: store_session_document.user_id
        #             resident: store_session_document.resident_username
        #     # Session.set 'displaying_profile', null
        #     #
        #     Router.go "/add_guest/#{new_guest_id}"

        # 'click .sign_rules': ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     new_id = Docs.insert
        #         model:'rules_and_regs_signing'
        #         session_id: store_session_document._id
        #         resident_id: store_session_document.user_id
        #         resident: store_session_document.resident_username
        #     Router.go "/sign_rules/#{new_id}/#{store_session_document.resident_username}"
        #     # Session.set 'displaying_profile',null


        # 'click .sign_guidelines': ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     new_id = Docs.insert
        #         model:'member_guidelines_signing'
        #         session_id: store_session_document._id
        #         resident_id: store_session_document.user_id
        #         resident: store_session_document.resident_username
        #     Router.go "/sign_guidelines/#{new_id}/#{store_session_document.resident_username}"
        #     # Session.set 'displaying_profile',null

                
        # 'click .add_recent_guest': ->
        #     current_session = Docs.findOne
        #         model:'store_session'
        #         current:true
        #     Docs.update current_session._id,
        #         $addToSet:guest_ids:@_id

        'click .remove_cart_item': (e,t)->
            current_session = Docs.findOne
                model:'store_session'
                # current:true
            # console.log current_session
            # console.log @valueOf()
            $(e.currentTarget).closest('.item').transition('slide left', 1000)
            Meteor.setTimeout =>            
                Docs.update current_session._id,
                    $pull:cart_product_ids:@_id
                $('body').toast({
                    message: 'item removed'
                })
            , 1000
    

        # 'click .toggle_adding_guest': ->
        #     Session.set 'adding_guest', true
        #     Session.set 'timer_engaged', false

        # 'click .submit_checkin': (e,t)->
        #     Meteor.call 'submit_checkin'

        # 'click .cancel_auto_checkin': (e,t)->
        #     Session.set 'timer_engaged',false

    Template.store_session.helpers
        products: ->
            Docs.find
                model:'product'
        # current_poll: ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     # store_session_document.user_id

        #     Docs.findOne
        #         model:'vote'
        #         upvoter_ids: $nin:[store_session_document.user_id]
        #         downvoter_ids: $nin:[store_session_document.user_id]



        # timer_engaged: ->
        #     Session.get 'timer_engaged'
        # timer: ->
        #     Session.get 'timer'
        #     # console.log Template.instance()
        #     # Template.instance().timer.get()

        # rules_signed: ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     if store_session_document.user_id
        #         resident = Meteor.users.findOne store_session_document.user_id
        #         # if resident.user_id
        #         Docs.findOne
        #             model:'rules_and_regs_signing'
        #             resident:resident.username
        # session_document: -> Docs.findOne Router.current().params.doc_id

        # adding_guests: -> Session.get 'adding_guest'
        # checking_in_doc: ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log store_session_document
        #     store_session_document
        # checkin_guest_docs: () ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     Docs.find
        #         _id:$in:store_session_document.guest_ids

        # user: ->
        #     store_session_document = Docs.findOne Router.current().params.doc_id
        #     if store_session_document and store_session_document.user_id
        #         Meteor.users.findOne store_session_document.user_id

    Template.session_product.events
        'click .add_to_cart': ->
            current_session = Docs.findOne
                model:'store_session'
                # current:true
            Docs.update current_session._id,
                $addToSet:
                    cart_product_ids:@_id
            $('body').toast({
                title: "added to cart"
                # message: 'See desk staff for key.'
                class : 'green'
                position:'top right'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
            })



if Meteor.isServer
    Meteor.publish 'session_products', (session_id)->
        Docs.find { 
            model:'product'
            app:'nf'
        }, limit:10