globalHotkeys = new Hotkeys();

# Template.shortcut_modal.onCreated ->
#     Meteor.subscribe 'model_docs', 'keyboard_shortcut'
# Template.shortcut_modal.helpers
#     shortcuts: ->
#         Docs.find
#             model:'keyboard_shortcut'
            
globalHotkeys.add
	combo: "d r"
	callback: ->
        model_slug =  Router.current().params.model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false

globalHotkeys.add
	combo: "d c"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        Router.go "/model/edit/#{model._id}"

globalHotkeys.add
	combo: "d s"
	callback: ->
        model = Docs.findOne Router.current().params.doc_id
        Router.go "/m/#{model.slug}"

globalHotkeys.add
	combo: "d e"
	callback: ->
        doc = Docs.findOne Router.current().params.doc_id
        Router.go "/m/#{doc.model}/#{doc._id}/edit"
globalHotkeys.add
	combo: "r a"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'admin' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'admin'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'admin'
globalHotkeys.add
	combo: "r m"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'student' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'student'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'student'
globalHotkeys.add
	combo: "r s"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'staff' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'staff'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'staff'
# globalHotkeys.add
# 	combo: "r m"
# 	callback: ->
#         if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
#             if 'manager' in Meteor.user().roles
#                 Meteor.users.update Meteor.userId(), $pull:roles:'manager'
#             else
#                 Meteor.users.update Meteor.userId(), $addToSet:roles:'manager'
globalHotkeys.add
	combo: "r d"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'dev'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'dev'
globalHotkeys.add
	combo: "r o"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'owner' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'owner'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'owner'

globalHotkeys.add
	combo: "r r"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'student' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'student'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'student'
globalHotkeys.add
	combo: "r f"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            if 'frontdesk' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'frontdesk'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'frontdesk'


# globalHotkeys.add
# 	combo: "m r "
# 	callback: ->
#         if Meteor.userId()
#             Meteor.call ''
#                 Meteor.users.update Meteor.userId(), $pull:roles:'frontdesk'
#             else
#                 Meteor.users.update Meteor.userId(), $addToSet:roles:'frontdesk'



globalHotkeys.add
	combo: "g h"
	callback: -> Router.go '/'
globalHotkeys.add
	combo: "g d"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['SqAW5apg4YXsk8Gab','JeFMvf2mpZFTjBsTS']
            Router.go '/dev'

globalHotkeys.add
	combo: "g l"
	callback: -> Router.go '/healthclub'
globalHotkeys.add
	combo: "g k"
	callback: -> Router.go '/karma'
globalHotkeys.add
	combo: "s d"
	callback: ->
        current_model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        Router.go "/m/#{current_model.slug}/#{Router.current().params.doc_id}/view"
globalHotkeys.add
	combo: "g u"
	callback: ->
        model_slug =  Router.current().params.model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false
        Router.go "/m/#{model_slug}/"
globalHotkeys.add
	combo: "g p"
	callback: -> Router.go "/user/#{Meteor.user().username}"
globalHotkeys.add
	combo: "g i"
	callback: -> Router.go "/inbox"
# globalHotkeys.add
# 	combo: "g m"
# 	callback: -> Router.go "/students"
globalHotkeys.add
	combo: "g a"
	callback: -> Router.go "/admin"
globalHotkeys.add
	combo: "g s"
	callback: -> Router.go "/staff"
globalHotkeys.add
	combo: "g c"
	callback: -> Router.go "/chat"
globalHotkeys.add
	combo: "g t"
	callback: -> Router.go "/m/task"
globalHotkeys.add
	combo: "g a"
	callback: -> Router.go "/admin"


globalHotkeys.add
	combo: "a d"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        # console.log model
        if model.collection and model.collection is 'users'
            name = prompt 'first and last name'
            split = name.split ' '
            first_name = split[0]
            last_name = split[1]
            username = name.split(' ').join('_')
            # console.log username
            Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                    Router.go "/m/#{model.slug}/#{res}/edit"
        else
            new_doc_id = Docs.insert
                model:model.slug
            Router.go "/m/#{model.slug}/#{new_doc_id}/edit"
