module Clear::Model::HasRelations
  #
  # ```
  # class Model
  #   include Clear::Model
  #
  #   has posts : Array(Post), [ foreign_key: Model.underscore_name + "_id", no_cache : false]
  #
  #   has passport : Passport
  # ```
  #
  macro has(name, foreign_key = nil, no_cache = false)
    {% if name.type.is_a?(Generic) && "#{name.type.name}" == "Array" %}
      {% if name.type.type_vars.size != 1 %}
        {% raise "has method accept only Array(Model) for has many behavior. Unions are not accepted" %}
      {% end %}

      {% t = name.type.type_vars[0].resolve %}
      {% if t < Clear::Model %}
        # Here the has many code
        def {{name.var.id}} : {{t}}::Collection
          %foreign_key =  {{foreign_key}} || ( self.class.table.to_s.singularize + "_id" )
          {{t}}.query.where{ raw(%foreign_key) == pkey }
        end
      {% else %}
        {% raise "Use `has` with an Array of model, or a single model. `#{t}` is not a valid model" %}
      {% end %}
    {% else %}
      {% t = name.type %}
      def {{name.var.id}} : {{t}}?
        %foreign_key =  {{foreign_key}} || ( self.class.table.to_s.singularize + "_id" )
        {{t}}.query.where{ raw(%foreign_key) == pkey }.first
      end
      # Here the has one code.
    {% end %}
  end

  macro belongs_to(name, foreign_key = nil, no_cache = false)
    {% t = name.type %}
    def {{name.var.id}} : {{t}}?
      {% foreign_key = foreign_key || t.stringify.underscore + "_id" %}
      {{t}}.query.where{ raw({{t}}.pkey) == self.{{foreign_key.id}} }.first
    end
  end
end