package org.regeinc.lang.generator

import org.regeinc.lang.el.And
import org.regeinc.lang.el.Comparison
import org.regeinc.lang.el.Condition
import org.regeinc.lang.el.Not

import static extension org.regeinc.lang.generator.ConditionJ.*

class ConditionJ {
	private new(){		
	}
	static ConditionJ conditionJ
	def static ConditionJ instance(){
		if(conditionJ==null)
			conditionJ = new ConditionJ()
		return conditionJ
	}
	
	def compile(Condition condition)'''
		«compile(condition.and)»«IF condition.OR» || «compile(condition.condition)»«ENDIF»'''

	def compile(And and)'''
		«compile(and.not)»«IF and.and!=null» && «compile(and.and)»«ENDIF»'''  

	def compile(Not not)'''
		«IF not.NOT»!«ENDIF»«IF not.comparison!=null»«compile(not.comparison)»«
			ELSEIF not.groupCondition!=null»( «compile(not.groupCondition.condition)» )«ENDIF»'''
	
	def compile(Comparison comparison)'''
		«IF comparison.RExpression!=null»«
			IF comparison.IN»«ExpressionJ::instance.compile(comparison.RExpression)».contains(«ExpressionJ::instance.compile(comparison.expression)»)«
			ELSE»«ExpressionJ::instance.compile(comparison.expression)» «
				IF comparison.EQUAL»==«
				ELSEIF comparison.NOTEQUAL»!=«
				ELSEIF comparison.LESSTHAN»>«
				ELSEIF comparison.GREATERTHAN»>«
				ELSEIF comparison.LESSTHANOREQUAL»<=«
				ELSEIF comparison.GREATERTHANOREQUAL»>=«
				ENDIF» «ExpressionJ::instance.compile(comparison.RExpression)»«
			ENDIF»«
		ELSE»«ExpressionJ::instance.compile(comparison.expression)»«
			IF comparison.IS» .is«comparison.state.toString.toFirstUpper»()«
			ELSEIF comparison.TYPEOF» instanceof «comparison.type.name»«
			ENDIF»«
		ENDIF»'''

	def applyConstraint(Condition condition)'''
		if(!(«compile(condition)»)){
			throw new IllegalArgumentException("declared constraint not satisfied");
		}
	'''		
}