if Meteor.isClient
    Router.route '/alerts/', (->
        @layout 'layout'
        @render 'alerts'
        ), name:'alerts'

    Template.alerts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'alert'
    Template.alerts.onRendered ->
        Meteor.setTimeout ->
            # $('.dropdown').dropdown(
            #     on:'click'
            # )
            $('.ui.dropdown').dropdown(
                clearable:true
                action: 'activate'
                onChange: (text,value,$selectedItem)->
                    )
        , 1000

    Template.alerts.helpers
        my_alerts: ->
            Docs.find
                model:'alert'
                target_username: Meteor.user().username
        alerts: ->
            Docs.find
                model:'alert'



    Template.alerts.events
        'click .submit_message': ->
            message = $('.message').val()
            console.log message
            Docs.insert
                model:'alerts'
                message:message
