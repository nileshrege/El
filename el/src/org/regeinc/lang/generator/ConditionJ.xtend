package org.regeinc.lang.generator

import org.regeinc.lang.el.OrCondition
import org.regeinc.lang.el.AndCondition
import org.regeinc.lang.el.NotCondition
import org.regeinc.lang.el.Condition

class ConditionJ {
	private new(){		
	}
	static ConditionJ conditionJ
	def static ConditionJ instance(){
		if(conditionJ==null)
			conditionJ = new ConditionJ()
		return conditionJ
	}
	
	def compile(OrCondition orCondition)'''
		«compile(orCondition.andCondition)»«IF orCondition.orCondition!=null» || «compile(orCondition.orCondition)»«ENDIF»'''

	def compile(AndCondition andCondition)'''
		«compile(andCondition.notCondition)»«IF andCondition.andCondition!=null» && «compile(andCondition.andCondition)»«ENDIF»'''  

	def compile(NotCondition notCondition)'''
		«IF notCondition.NOT»!«ENDIF»«compile(notCondition.condition)»'''

	def compile(Condition condition)'''
		«IF condition.instance!=null»«InstanceJ::instance.compile(condition.instance)»«
		ELSEIF condition.groupCondition!=null»(«compile(condition.groupCondition.orCondition)»)«ENDIF»'''

	def applyConstraint(OrCondition orCondition)'''
		if(!(«compile(orCondition)»)){
			throw new IllegalArgumentException("declared constraint not satisfied");
		}
	'''		
}