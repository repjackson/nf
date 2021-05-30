Meteor.methods
    call_wiki: (query)->
        console.log 'calling wiki', query
        # term = query.split(' ').join('_')
        # term = query[0]
        @unblock()
        term = query
        # HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
        HTTP.get "https://en.wikipedia.org/w/api.php?action=opensearch&generator=searchformat=json&search=#{term}",(err,response)=>
            if err
                console.log 'error finding wiki article for ', query
            else
                console.log response.data[1]
                for term,i in response.data[1]
                    # console.log 'term', term
                    # console.log 'i', i
                    # console.log 'url', response.data[3][i]
                    url = response.data[3][i]
    
                #     # console.log response
                #     # console.log 'response'
    
                    found_doc =
                        Docs.findOne
                            url: url
                            model:'wikipedia'
                    if found_doc
                        # console.log 'found wiki doc for term', term
                        # console.log 'found wiki doc for term', term, found_doc
                        # Docs.update found_doc._id,
                        #     # $pull:
                        #     #     tags:'wikipedia'
                        #     $set:
                        #         title:found_doc.title.toLowerCase()
                        # console.log 'found wiki doc', found_doc.title
                        unless found_doc.watson
                            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                    else
                        new_wiki_id = Docs.insert
                            title:term.toLowerCase()
                            tags:[term.toLowerCase()]
                            source: 'wikipedia'
                            model:'wikipedia'
                            # ups: 1
                            url:url
                        Meteor.call 'call_watson', new_wiki_id, 'url','url', ->