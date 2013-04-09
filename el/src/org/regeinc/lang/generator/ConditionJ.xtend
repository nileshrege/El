package org.regeinc.lang.generator

import org.regeinc.lang.el.AndCondition
import org.regeinc.lang.el.Comparison
import org.regeinc.lang.el.Condition
import org.regeinc.lang.el.NotCondition

import static extension org.regeinc.lang.generator.ConditionJ.*
import org.regeinc.lang.el.TypeComparison
import org.regeinc.lang.el.StateComparison
import org.regeinc.lang.el.AssociativeComparison

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
		«ExpressionJ::instance.compile(comparison.expression)»«IF comparison.associativeComparison!=null»«compile(comparison.associativeComparison)»«
		ELSEIF comparison.stateComparison!=null»«compile(comparison.stateComparison)»«
		ELSEIF comparison.typeComparison!=null»«compile(comparison.typeComparison)»«ENDIF»'''

	def compile(AssociativeComparison associativeComparison)'''
		«associativeComparison.comparator» «ExpressionJ::instance.compile(associativeComparison.expression)»'''

	def compile(StateComparison stateComparison)'''
		.is«stateComparison.state.name.toString.toFirstUpper»()'''
		
	def compile(TypeComparison typeComparison)'''
		instanceof «typeComparison.type.name»'''

	def applyConstraint(Condition condition)'''
		if(!(«compile(condition)»)){
			throw new IllegalArgumentException("declared constraint not satisfied");
		}
	'''		
}