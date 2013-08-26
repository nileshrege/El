package org.regeinc.lang.generator

import org.regeinc.lang.el.AndCondition
import org.regeinc.lang.el.AssociativeComparison
import org.regeinc.lang.el.Comparison
import org.regeinc.lang.el.Condition
import org.regeinc.lang.el.NotCondition
import org.regeinc.lang.el.StateComparison
import org.regeinc.lang.el.TypeComparison

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
		«compile(condition.andCondition)»«IF condition.OR» || «compile(condition.condition)»«ENDIF»'''

	def compile(AndCondition andCondition)'''
		«compile(andCondition.notCondition)»«IF andCondition.andCondition!=null» && «compile(andCondition.andCondition)»«ENDIF»'''  

	def compile(NotCondition notCondition)'''
		«IF notCondition.NOT»!«ENDIF»«IF notCondition.comparison!=null»«compile(notCondition.comparison)»«
			ELSEIF notCondition.groupCondition!=null»( «compile(notCondition.groupCondition.condition)» )«ENDIF»'''
	
	def compile(Comparison comparison)'''
		«IF comparison.stateComparison!=null»«compile(comparison.stateComparison)»
		«ELSEIF comparison.typeComparison!=null»«compile(comparison.typeComparison)»
		«ELSEIF comparison.associativeComparison!=null»«
			IF comparison.associativeComparison.comparator.toString.equals("in")»«
				ExpressionJ::instance.compile(comparison.associativeComparison.expression)».contains(«
					ExpressionJ::instance.compile(comparison.expression)»)«
			ELSEIF comparison.associativeComparison.comparator.toString.equals("?=")»«
				ExpressionJ::instance.compile(comparison.expression)».equals(«
					ExpressionJ::instance.compile(comparison.associativeComparison.expression)»)«
			ELSE»«ExpressionJ::instance.compile(comparison.expression)» «compile(comparison.associativeComparison)»«
			ENDIF»«
		ENDIF»'''

	def compile(AssociativeComparison associativeComparison)'''
		«associativeComparison.comparator» «ExpressionJ::instance.compile(associativeComparison.expression)»'''

	def compile(StateComparison stateComparison)'''
		.is«stateComparison.state.name.toString.toFirstUpper»()'''
		
	def compile(TypeComparison typeComparison)'''
		instanceof «typeComparison.type.name»'''

	def applyConstraint(Condition condition, String context)'''
		if(!(«compile(condition)»)){
			throw new IllegalArgumentException("declared constraint on «context» not satisfied");
		}
	'''		
}