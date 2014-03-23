require '../../spec_helper'

describe 'dhField directive', ->
  el = scope = item = Cards = null

  beforeEach angular.mock.module 'Deckhand'

  beforeEach angular.mock.module ($provide) ->
    $provide.value 'ModelConfigData',
      'Model':
        prop:
          type: 'relation'
    undefined

  describe 'when the field is of type = relation', ->
    beforeEach inject ($compile, $rootScope, _Cards_) ->
      Cards = _Cards_
      outerScope = $rootScope.$new()
      item = outerScope.item =
        _model: 'Model'
        prop:
          _model: 'AnotherModel'
          id: 123
          _label: 'Some prop description'

      spyOn(Cards, 'show')

      html = '''
        <dh-field item="item" model="'Model'" name="'prop'"/>
      '''
      el = $compile(html)(outerScope)
      outerScope.$apply()

    it 'renders a link', ->
      expect(el.find('a')).toExist()

    it 'shows the label of the related object', ->
      expect(el).toHaveText(item.prop._label)

    describe 'when clicking the link', ->
      beforeEach ->
        el.find('a').click()

      it 'shows the corresponding card', ->
        expect(Cards.show).toHaveBeenCalledWith(item.prop._model, item.prop.id)
