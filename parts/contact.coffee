if Meteor.isClient
    Router.route '/contact', (->
        @layout 'layout'
        @render 'contact'
        ), name:'contact'


    Template.contact.onCreated ->
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'contact_submissions'

    Template.contact.events
        'keyup .contact': _.throttle((e,t)->
            query = $('#contact').val()
            Session.set('contact', query)
            # console.log Session.get('contact')
            if e.key == "Escape"
                Session.set('contact', null)
                
            if e.which is 13
                search = $('#contact').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#contact').val('')
                    Session.set('contact', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

    Template.contact.helpers
        contact_submissions: ->
            Docs.find
                model:'contact_submission'


if Meteor.isServer
    Meteor.publish 'contact_submissions', ()->
        Docs.find 
            model:'contact_submission'