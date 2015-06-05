shared_examples :scope_specs do
  describe 'scope' do
    let(:view) {
      string = <<-D
      <div data-scope="post">
        <h1 data-prop="title">title</h1>
        <div>
          <p data-prop="body">body</p>
        </div>
        <div data-scope="comment"></div>
        <div data-scope="comment"></div>
      </div>
      D

      View.from_doc(doctype.new(string))
    }

    it 'finds single scope' do
      expect(view.scope(:post).length).to eq(1)
      expect(view.scope('post').length).to eq(1)
    end

    it 'finds multiple scopes' do
      expect(view.scope(:post).scope(:comment).length).to eq(2)
    end

    it 'finds nested scopes' do
      expect(view.scope(:comment).length).to eq(0)
      expect(view.scope(:post).length).to eq(1)
      expect(view.scope(:post).scope(:comment).length).to eq(2)
    end

    it 'ignores invalid scopes' do
      expect(view.scope(:fail).length).to eq(0)
    end

    it 'finds props' do
      expect(view.scope(:post).prop(:title)[0].html).to eq('title')
      expect(view.scope(:post).prop(:body)[0].html).to eq('body')
    end

    it 'does not nest scope within itself' do
      post_binding = view.doc.scopes.first
      post_binding[:nested].each {|nested|
        expect(nested[:doc]).not_to eq(post_binding[:doc])
      }
    end

    context 'when there is an unused partial in the path' do
      let :view do
        ViewContext.new(ViewComposer.from_path(store, 'scope_with_unused_partial'), {})
      end

      let :data do
        { name: 'foo' }
      end

      it 'binds data to the scope' do
        view = ViewContext.new(ViewComposer.from_path(ViewStore.new(VIEW_PATH), 'scope_with_unused_partial'), {})
        expect(view.scope(:article).instance_variable_get(:@view).views.count).to eq(1)
      end
    end
  end
end
