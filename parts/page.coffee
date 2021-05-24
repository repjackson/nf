if Meteor.isClient
    Router.route '/p/:slug', (->
        @layout 'layout'
        @render 'page'
        ), name:'page'

    Router.route '/team', (->
        @layout 'layout'
        @render 'team'
        ), name:'team'

    Template.page.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'page_doc', Router.current().params.slug
    Template.page.events
        'click .create_page': ->
            Docs.insert
                model:'page'
                slug:Router.current().params.slug
    Template.page.helpers
        page_doc: ->
            Docs.findOne
                model:'page'
                slug:Router.current().params.slug


    Template.team.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'model_docs', 'person'
    Template.team.events
        # 'click .create_page': ->
        #     Docs.insert
        #         model:'page'
        #         slug:Router.current().params.slug

    Template.team.helpers
        founders: ->
            Docs.find
                model:'person'
                founder:true
        contributors: ->
            Docs.find
                model:'person'
                contributor:true

if Meteor.isServer
    Meteor.publish 'page_doc', (page_slug)->
        Docs.find
            model:'page'
            slug:page_slug
