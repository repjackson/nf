if Meteor.isClient
    Router.route '/mail', (->
        @layout 'layout'
        @render 'mail'
        ), name:'mail'
    Router.route '/mail/drafts', (->
        @layout 'layout'
        @render 'mail_drafts'
        ), name:'mail_drafts'
    Router.route '/mail/sent', (->
        @layout 'layout'
        @render 'mail_sent'
        ), name:'mail_sent'
    Router.route '/mail/archived', (->
        @layout 'layout'
        @render 'mail_archived'
        ), name:'mail_archived'
    Router.route '/mail/trash', (->
        @layout 'layout'
        @render 'mail_trash'
        ), name:'mail_trash'


    Router.route '/message/:doc_id/edit', (->
        @layout 'layout'
        @render 'message_edit'
        ), name:'message_edit'
    Router.route '/message/:doc_id/view', (->
        @layout 'layout'
        @render 'message_view'
        ), name:'message_view'




    Template.message_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.message_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->


    Template.mail.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'message'
    Template.mail.helpers
        mail_view_mode: -> Session.get 'mail_view_mode'
        mail_view_mode_label: -> Session.get 'mail_view_mode_label'
        mail_view_mode_icon: -> Session.get 'mail_view_mode_icon'
        current_view_messages: ->
            mail_view_mode = Session.get 'mail_view_mode'
            if mail_view_mode is 'all'
                Docs.find
                    model:'message'
            else
                Docs.find
                    model:'message'
                    status: mail_view_mode

    Template.mail.events
        'click .add_message': ->
            new_message_id = Docs.insert
                model:'message'
            Router.go "/message/#{new_message_id}/edit"



    Template.mail_view_menu_item.helpers
        view_count: ->
            # console.log @
            match = {}
            # if @
            Docs.find(
                model:'message'
                archived:false
                recipient: Meteor.user().username
            ).count()

        menu_item_class: -> if Session.equals('mail_view_mode', @slug) then 'active' else ''
    Template.mail_view_menu_item.events
        'click .set_view': ->
            Session.set 'mail_view_mode', @slug
            Session.set 'mail_view_mode_label', @label
            Session.set 'mail_view_mode_icon', @icon


    Template.mail.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.mail.helpers
        messages: ->
            Docs.find
                model:'message'
    Template.mail.events
        'click .compose': ->
            new_message_id = Docs.insert
                model:'message'
            Router.go "/message/#{new_message_id}/edit"

        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'messages'
                message:message




    Template.message_edit.onRendered ->
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.message_edit.events
        'click .save_draft': ->
            Docs.update @_id,
                $set:
                    status:'draft'
        'click .send': ->
            Docs.update @_id,
                $set:
                    status:'sent'