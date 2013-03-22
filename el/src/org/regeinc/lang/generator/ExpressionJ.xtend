package org.regeinc.lang.generator

import org.regeinc.lang.el.Expression
import org.regeinc.lang.el.Instance
import org.regeinc.lang.el.NewInstance
import org.regeinc.lang.el.ListInstance
import org.regeinc.lang.el.Literal
import org.regeinc.lang.el.DECIMAL_LITERAL
import org.regeinc.lang.el.Argument
import org.regeinc.lang.el.State
import org.regeinc.lang.el.TypeRef
import org.regeinc.lang.el.StateOrTypeRef

class ExpressionJ{
	private new(){		
	}
	static ExpressionJ expressionJ
	def static ExpressionJ instance(){
		if(expressionJ==null)
			expressionJ = new ExpressionJ()
		return expressionJ
	}
	
	def compile(Expression expression)'''
		«compile(expression.instance)»«
		IF expression.expression!=null»«expression.operator.toString»«compile(expression.expression)»«ENDIF»'''
		
	def compile(Instance instance)'''
		«IF instance.stateOrTypeRef!=null»«compile(instance.stateOrTypeRef)»«
		ELSEIF instance.methodCall!=null»«MethodJ::instance.compile(instance.methodCall)»«
		ELSEIF instance.literal!=null»«compile(instance.literal)»«
		ELSEIF instance.listInstance!=null»«compile(instance.listInstance)»«
		ELSEIF instance.newInstance!=null»«compile(instance.newInstance)»«ENDIF»'''
		
	def compile(NewInstance newInstance)'''
		new «newInstance.entity.name»(«IF newInstance.argument!=null»«ENDIF»)«
			IF !newInstance.allNestedInstance.nullOrEmpty»«
				FOR nestedInstance:newInstance.allNestedInstance
					».with«nestedInstance.specificTypeRef.typeRef.name.toFirstUpper»(«compile(nestedInstance.expression)»)«
				ENDFOR»«
			ENDIF»'''

	def compile(StateOrTypeRef stateOrVariable)'''
		«IF stateOrVariable instanceof State»is«(stateOrVariable as State).name.toFirstUpper»()«
			ELSEIF stateOrVariable instanceof TypeRef»«(stateOrVariable as TypeRef).name»«ENDIF»'''

	def compileReferred(StateOrTypeRef stateOrVariable)'''
		.«IF stateOrVariable instanceof State»is«(stateOrVariable as State).name.toFirstUpper»()«
			ELSEIF stateOrVariable instanceof TypeRef»get«(stateOrVariable as TypeRef).name.toFirstUpper»()«ENDIF»'''
	
	def compile(ListInstance listInstance)'''
		java.util.Arrays.asList(«compile(listInstance.argument)»)'''	

	def compile(Argument argument)'''
		«compile(argument.expression)»«IF argument.list», «compile(argument.next)»«ENDIF»'''
	
	def compile(Literal literal)'''
		«IF literal.string!=null»«IF literal.string.length>0»«literal.string»«ELSE»""«ENDIF»«
		ELSEIF literal.number!=null»«compile(literal.number)»«
		ELSEIF literal.THIS!=null»this«
		ELSEIF literal.NULL!=null»null«
		ELSEIF literal.TRUE!=null»true«
		ELSEIF literal.FALSE!=null»false«ENDIF»'''

	def compile(DECIMAL_LITERAL decimal)'''
		«IF decimal.integer!=null»«decimal.integer»«ENDIF»«
			IF decimal.PERIOD».«decimal.fraction»«IF decimal.FLOATING»f«ENDIF»«ELSEIF decimal.TOOLONG»l«ENDIF»'''

}