package org.regeinc.lang.generator

import org.regeinc.lang.el.Argument
import org.regeinc.lang.el.DECIMAL_LITERAL
import org.regeinc.lang.el.Expression
import org.regeinc.lang.el.Instance
import org.regeinc.lang.el.ListInstance
import org.regeinc.lang.el.Literal
import org.regeinc.lang.el.NewInstance

import static extension org.regeinc.lang.generator.ExpressionJ.*
import org.regeinc.lang.el.StateOrReference
import org.regeinc.lang.el.State
import org.regeinc.lang.el.Reference
import org.regeinc.lang.el.Substraction
import org.regeinc.lang.el.Addition
import org.regeinc.lang.el.Division

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
	«IF expression.division!=null»«compile(expression.division)»«ENDIF»«IF expression.ASTERIX» * «compile(expression.expression)»«ENDIF»'''
	
	def compile(Division division)'''
	«IF division.addition!=null»«compile(division.addition)»«ENDIF»«IF division.PERCENT» % «compile(division.division)»«ENDIF»'''
	
	def compile(Addition addition)'''
	«IF addition.substraction!=null»«compile(addition.substraction)»«ENDIF»«IF addition.PLUS» + «compile(addition.addition)»«ENDIF»'''
	
	def compile(Substraction  substraction)'''
	«IF substraction.instance!=null»«compile(substraction.instance)»«
	ELSEIF substraction.groupExpression!=null»(«compile(substraction.groupExpression)»)«
	ENDIF»«IF substraction.HYPHEN» - «compile(substraction.substraction)»«ENDIF»'''
		
	def compile(Instance instance)'''
		«IF instance.stateOrReference!=null»«compile(instance.stateOrReference)»«
		ELSEIF instance.literal!=null»«compile(instance.literal)»«
		ELSEIF instance.listInstance!=null»«compile(instance.listInstance)»«
		ELSEIF instance.newInstance!=null»«compile(instance.newInstance)»«ENDIF»«
		IF instance.dotMethodCall!=null»«MethodJ::instance.compile(instance.dotMethodCall)»«ENDIF»'''
	 
	def compile(StateOrReference stateOrReference)'''
		«IF stateOrReference instanceof State»is«(stateOrReference as State).name.toFirstUpper»()«
			ELSEIF stateOrReference instanceof Reference»«(stateOrReference as Reference).name»«ENDIF»'''
	
	def compile(NewInstance newInstance)'''
		new «newInstance.entity.name»(«IF newInstance.argument!=null»«ENDIF»)«
			IF !newInstance.allNestedInstance.nullOrEmpty»«
				FOR nestedInstance:newInstance.allNestedInstance
					».with«nestedInstance.qualifiedReference.reference.name.toFirstUpper»(«compile(nestedInstance.expression)»)«
				ENDFOR»«
			ENDIF»'''
	
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