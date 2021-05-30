# Router.route '/kiosk', (->
#     @layout 'mlayout'
#     @render 'kiosk_container'
#     ), name:'kiosk'



# if Meteor.isClient
#     Template.kiosk_settings.onCreated ->
#         @autorun -> Meteor.subscribe 'kiosk_document'

#     Template.kiosk_container.onCreated ->
#         @autorun -> Meteor.subscribe 'kiosk_document'

#     Template.kiosk_settings.onRendered ->
#         # Meteor.setTimeout ->
#         #     $('.button').popup()
#         # , 3000

#     Template.set_kiosk_template.events
#         'click .set_kiosk_template': ->
#             kiosk_doc = Docs.findOne
#                 model:'kiosk'
#             Docs.update kiosk_doc._id,
#                 $set:kiosk_view:@value





#     Template.kiosk_settings.events
#         'click .create_kiosk': (e,t)->
#             Docs.insert
#                 model:'kiosk'

#         'click .print_kiosk': (e,t)->
#             kiosk = Docs.findOne model:'kiosk'
#             console.log kiosk

#         'click .delete_kiosk': (e,t)->
#             kiosk = Docs.findOne model:'kiosk'
#             if kiosk
#                 if confirm "delete  #{kiosk._id}?"
#                     Docs.remove kiosk._id

#     Template.kiosk_settings.helpers
#         kiosk_doc: ->
#             Docs.findOne
#                 model:'kiosk'
#         kiosk_view: ->
#             kiosk_doc = Docs.findOne
#                 model:'kiosk'
#             kiosk_doc.kiosk_view

#     Template.kiosk_container.helpers
#         kiosk_doc: ->
#             Docs.findOne
#                 model:'kiosk'
#         kiosk_view: ->
#             kiosk_doc = Docs.findOne
#                 model:'kiosk'
#             kiosk_doc.kiosk_view




#     Template.resident_guest.onCreated ->
#         # console.log @
#         @autorun => Meteor.subscribe 'doc', @data
#     Template.resident_guest.helpers
#         guest_doc: ->
#             Docs.findOne Template.currentData()


#     Template.store_stats.events
#         'click .recalc': ->
#             console.log @
#             Meteor.call 'recalc_store_stats', @user



# if Meteor.isServer
#     Meteor.publish 'kiosk_document', ()->
#         Docs.find
#             model:'kiosk'

#     Meteor.methods
#         kiosk_vote_no: (poll_id, user_id)->
#             console.log poll_id, user_id
#             Docs.update poll_id,
#                 $addToSet: downvoter_ids: user_id
#         kiosk_vote_yes: (poll_id, user_id)->
#             console.log poll_id, user_id
#             Docs.update poll_id,
#                 $addToSet: upvoter_ids: user_id


#         recalc_store_stats: (user)->
#             # console.log user
#             session_count =
#                 Docs.find(
#                     model:'store_session'
#                     user_id:user._id
#                 ).count()
#             # console.log session_count
#             Meteor.users.update user._id,
#                 $set:total_session_count:session_count
#             sorted_session_count =
#                 Meteor.users.find({
#                     total_session_count:$exists:1
#                 },
#                     sort:total_session_count:-1
#                     fields:
#                         username:1
#                         total_session_count:1
#                 ).fetch()
#             # console.log total_top_ten
#             found_in_ranking = _.findWhere(sorted_session_count,{username:user.username})
#             console.log 'found', found_in_ranking
#             global_rank = _.indexOf(sorted_session_count,found_in_ranking)+1
#             if global_rank > 0
#                 Meteor.users.update user._id,
#                     $set:global_rank:global_rank

#     publishComposite 'store_session', (doc_id)->
#         {
#             find: ->
#                 Docs.find doc_id
#             children: [
#                 { find: (doc) ->
#                     Meteor.users.find
#                         _id: doc.user_id
#                     }
#                 { find: (doc) ->
#                     Docs.find
#                         model: 'guest'
#                         _id:doc.guest_ids
#                     }
#                 ]
#         }