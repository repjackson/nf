if Meteor.isClient
    Template.home_slider.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'slide'
    Template.home_slider.onRendered ->
        Meteor.setTimeout ->
            $('#slider').layerSlider({
                sliderVersion: '6.0.0',
                type: 'fullwidth',
                responsiveUnder: 1200,
                autoStart: true,
                maxRatio: 1,
                slideBGSize: 'auto',
                fullSizeMode: 'hero'
                fitScreenWidth: true
                allowFullscreen: true
                skin: 'numbers',
                globalBGColor: '#fbfbfa',
                thumbnailNavigation: false,
                tnWidth: 170,
                tnHeight: 120,
                skinsPath: '../../layerslider/skins/'
            });
        , 2000

    Template.home_slider.helpers
        slides: ->
            # console.log Docs.find(model:'slide').fetch()
            # []
            Docs.find {
                model:'slide'
            }, sort: number:-1