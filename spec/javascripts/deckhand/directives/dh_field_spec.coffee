require '../../spec_helper'

describe 'dhField directive', ->
  el = outerScope = item = modelConfigData = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach angular.mock.module ($provide) ->
    modelConfigData =
      'Model':
        relationProp:
          type: 'relation'
        timeProp:
          type: 'time'
        thumbnailProp:
          thumbnail: true
        linkToProp:
          link_to: 'http://some.url/that/has/the/:value'

    $provide.value 'ModelConfigData', modelConfigData
    undefined

  beforeEach inject ($rootScope) ->
    outerScope = $rootScope.$new()
    item = outerScope.item =
      _model: 'Model'
      prop: 'A regular prop'
      timeProp: new Date().valueOf()
      relationProp:
        _model: 'AnotherModel'
        id: 123
        _label: 'Some prop description'
      thumbnailProp: 'http://some.url/to/an/image.png'
      linkToProp: 'chimichangas'

  describe 'when the field has no special properties', ->
    beforeEach inject ($compile, $rootScope) ->
      html = '''
        <dh-field item="item" model="'Model'" name="'prop'"/>
      '''
      el = $compile(html)(outerScope)
      outerScope.$apply()

    it 'renders the value', ->
      expect(el).toHaveText(item.prop)

  describe 'when the field is of type = relation', ->
    Cards = null

    beforeEach inject ($compile, $rootScope, _Cards_) ->
      Cards = _Cards_
      spyOn(Cards, 'show')
      html = '''
        <dh-field item="item" model="'Model'" name="'relationProp'"/>
      '''
      el = $compile(html)(outerScope)
      outerScope.$apply()

    it 'renders a link', ->
      expect(el.find('a')).toExist()

    it 'shows the label of the related object', ->
      expect(el).toHaveText(item.relationProp._label)

    describe 'when clicking the link', ->
      beforeEach ->
        el.find('a').click()

      it 'shows the corresponding card', ->
        expect(Cards.show).toHaveBeenCalledWith(item.relationProp._model, item.relationProp.id)

  describe 'when the field is of type = time', ->
    beforeEach inject ($compile, $rootScope) ->
      html = '''
        <dh-field item="item" model="'Model'" name="'timeProp'"/>
      '''
      el = $compile(html)(outerScope)
      outerScope.$apply()

    it 'renders a span with the short time', ->
      expect(el).toHaveText('a few seconds ago')


  describe 'when the field is a thumbnail', ->
    beforeEach inject ($compile, $rootScope) ->
      html = '''
        <dh-field item="item" model="'Model'" name="'thumbnailProp'"/>
      '''
      el = $compile(html)(outerScope)
      outerScope.$apply()

    it 'renders an external link to the prop value', ->
      expect(el.find('a')).toHaveAttr('href', item.thumbnailProp)
      expect(el.find('a')).toHaveAttr('target', '_blank')

    it 'renders an image inside the link with the value as src', ->
      expect(el.find('a img')).toHaveAttr('src', item.thumbnailProp)

  describe 'when the field is an external link', ->
    beforeEach inject ($compile, $rootScope) ->
      html = '''
        <dh-field item="item" model="'Model'" name="'linkToProp'"/>
      '''
      el = $compile(html)(outerScope)
      outerScope.$apply()

    it 'renders an external link to the prop value', ->
      href = modelConfigData.Model.linkToProp.link_to.replace(':value', item.linkToProp)
      expect(el.find('a')).toHaveAttr('href', href)
      expect(el.find('a')).toHaveAttr('target', '_blank')
